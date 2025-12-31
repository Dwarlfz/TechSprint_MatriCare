const { useState, useEffect, useRef } = React;

// Toast Component
function Toast({ message, type, onClose }) {
    useEffect(() => {
        const timer = setTimeout(() => {
            onClose();
        }, 3000);
        return () => clearTimeout(timer);
    }, [onClose]);

    const bgColors = {
        success: 'bg-green-500',
        error: 'bg-red-500',
        info: 'bg-blue-500'
    };

    return (
        <div className={`fixed bottom-4 right-4 ${bgColors[type] || 'bg-gray-800'} text-white px-6 py-3 rounded-lg shadow-xl flex items-center space-x-3 animate-bounce-in z-50`}>
            <i className={`fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}`}></i>
            <span>{message}</span>
            <button onClick={onClose} className="ml-4 hover:text-gray-200"><i className="fas fa-times"></i></button>
        </div>
    );
}

// Notification Popup Component
function NotificationPopup({ alerts, onClose }) {
    return (
        <div className="absolute top-16 right-4 w-80 bg-white dark:bg-gray-800 rounded-xl shadow-2xl border border-gray-100 dark:border-gray-700 z-50 animate-fade-in-up overflow-hidden">
            <div className="p-4 border-b border-gray-100 dark:border-gray-700 flex justify-between items-center">
                <h3 className="font-bold text-gray-800 dark:text-white">Notifications</h3>
                <button onClick={onClose} className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200">
                    <i className="fas fa-times"></i>
                </button>
            </div>
            <div className="max-h-96 overflow-y-auto">
                {alerts && alerts.length > 0 ? (
                    alerts.map((alert, index) => (
                        <div key={index} className="p-4 border-b border-gray-50 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 transition cursor-pointer">
                            <div className="flex items-start space-x-3">
                                <div className={`w-2 h-2 mt-2 rounded-full bg-${alert.color}-500 flex-shrink-0`}></div>
                                <div>
                                    <p className="text-sm font-semibold text-gray-800 dark:text-white">{alert.patient}</p>
                                    <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">{alert.message}</p>
                                    <p className="text-xs text-gray-400 mt-2">{alert.time}</p>
                                </div>
                            </div>
                        </div>
                    ))
                ) : (
                    <div className="p-8 text-center">
                        <i className="fas fa-bell-slash text-gray-300 dark:text-gray-600 text-4xl mb-3"></i>
                        <p className="text-gray-500 dark:text-gray-400 text-sm">No new notifications</p>
                    </div>
                )}
            </div>
            <div className="p-3 bg-gray-50 dark:bg-gray-700/50 text-center">
                <button className="text-xs font-medium text-blue-600 dark:text-blue-400 hover:underline">Mark all as read</button>
            </div>
        </div>
    );
}

// Main App Component
function App() {
    const [darkMode, setDarkMode] = useState(false);
    const [currentView, setCurrentView] = useState('dashboard');
    const [selectedPatient, setSelectedPatient] = useState(null);
    const [selectedAlert, setSelectedAlert] = useState(null);
    const [toast, setToast] = useState(null);
    const [showNotifications, setShowNotifications] = useState(false);

    // Data State
    const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState([]);
    const [fetalHRData, setFetalHRData] = useState(null);
    const [maternalVitals, setMaternalVitals] = useState([]);
    const [fetalMovementData, setFetalMovementData] = useState(null);
    const [patients, setPatients] = useState([]);
    const [alerts, setAlerts] = useState([]);

    // History State for Dynamic Graphs
    // Structure: { patientId: { fetalHR: [], maternalHR: [], bp: [], movement: [], timestamps: [] } }
    const [patientHistory, setPatientHistory] = useState({});

    // Firebase Initialization
    useEffect(() => {
        if (typeof initializeFirebase === 'function') {
            initializeFirebase();
        }
    }, []);

    // Authentication Check
    useEffect(() => {
        const isLoggedIn = sessionStorage.getItem('isLoggedIn');
        if (!isLoggedIn) {
            window.location.href = 'login.html';
        }
    }, []);

    // Scroll to top on view change
    useEffect(() => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }, [currentView]);

    // Dark Mode Effect
    useEffect(() => {
        if (darkMode) {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }, [darkMode]);

    // Fetch Data Effect
    useEffect(() => {
        const loadData = async () => {
            try {
                const data = await window.DataService.fetchData();
                if (data.stats.length === 0) {
                    setToast({ message: 'Failed to connect to server. Is server.py running?', type: 'error' });
                } else {
                    setStats(data.stats);
                    // setFetalHRData(data.fetalHR); // Deprecated static data
                    setMaternalVitals(data.maternalVitals);
                    setFetalMovementData(data.fetalMovement);
                    setPatients(data.patients);
                    setAlerts(data.alerts);

                    // Update History for first 3 patients
                    const timestamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    setPatientHistory(prevHistory => {
                        const newHistory = { ...prevHistory };

                        // We only track the first 3 patients for the demo
                        // Patient indices 0, 1, 2 correspond to IDs PT-2000, PT-2001, PT-2002
                        const targetPatients = data.patients.slice(0, 3);

                        targetPatients.forEach(patient => {
                            if (!newHistory[patient.id]) {
                                newHistory[patient.id] = {
                                    fetalHR: [],
                                    maternalHR: [],
                                    bp: [], // Store as string "120/80" or object
                                    movement: [],
                                    timestamps: []
                                };
                            }

                            // Limit history to last 10 points
                            const history = newHistory[patient.id];
                            if (history.timestamps.length > 10) {
                                history.fetalHR.shift();
                                history.maternalHR.shift();
                                history.bp.shift();
                                history.movement.shift();
                                history.timestamps.shift();
                            }

                            history.fetalHR.push(patient.vitals.fetalHR);
                            history.maternalHR.push(patient.vitals.maternalHR);
                            history.bp.push(patient.vitals.bp);
                            history.movement.push(patient.vitals.movement);
                            history.timestamps.push(timestamp);
                        });

                        return newHistory;
                    });
                }
                setLoading(false);
            } catch (error) {
                console.error("Failed to load data", error);
                setToast({ message: 'Error loading data', type: 'error' });
                setLoading(false);
            }
        };

        loadData();
        const interval = setInterval(loadData, 5000);
        return () => clearInterval(interval);
    }, []);

    const showToast = (message, type = 'success') => {
        setToast({ message, type });
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-blue-50 dark:bg-gray-900">
                <div className="text-center">
                    <div className="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-blue-500 mx-auto mb-4"></div>
                    <p className="text-gray-600 dark:text-gray-400">Connecting to server...</p>
                </div>
            </div>
        );
    }

    return (
        <div className={`min-h-screen ${darkMode ? 'dark' : ''}`}>
            <div className="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-gray-900 dark:to-gray-800 transition-colors duration-300 min-h-screen">
                <Navbar
                    darkMode={darkMode}
                    setDarkMode={setDarkMode}
                    currentView={currentView}
                    setCurrentView={setCurrentView}
                    showNotifications={showNotifications}
                    setShowNotifications={setShowNotifications}
                    alerts={alerts}
                />

                {showNotifications && (
                    <NotificationPopup alerts={alerts} onClose={() => setShowNotifications(false)} />
                )}

                <div className="animate-fade-in-up">
                    {currentView === 'dashboard' ? (
                        <DashboardView
                            setCurrentView={setCurrentView}
                            setSelectedPatient={setSelectedPatient}
                            setSelectedAlert={setSelectedAlert}
                            stats={stats}
                            patientHistory={patientHistory}
                            maternalVitals={maternalVitals}
                            fetalMovementData={fetalMovementData}
                            patients={patients}
                            alerts={alerts}
                        />
                    ) : currentView === 'profile' ? (
                        <PatientProfileView
                            setCurrentView={setCurrentView}
                            selectedPatient={selectedPatient}
                            patientHistory={patientHistory}
                            showToast={showToast}
                        />
                    ) : currentView === 'doctorProfile' ? (
                        <DoctorProfileView
                            setCurrentView={setCurrentView}
                            showToast={showToast}
                            alerts={alerts}
                        />
                    ) : (
                        <AlertDetailView
                            setCurrentView={setCurrentView}
                            selectedAlert={selectedAlert}
                            showToast={showToast}
                        />
                    )}
                </div>

                {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
            </div>
        </div>
    );
}

// Navbar Component
function Navbar({ darkMode, setDarkMode, currentView, setCurrentView, showNotifications, setShowNotifications, alerts }) {
    const handleLogout = () => {
        sessionStorage.removeItem('isLoggedIn');
        window.location.href = 'login.html';
    };

    return (
        <nav className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-md shadow-md sticky top-0 z-40 transition-colors duration-300">
            <div className="px-4 sm:px-6 lg:px-8 py-4">
                <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3 cursor-pointer" onClick={() => setCurrentView('dashboard')}>
                        <div className="w-12 h-12 bg-gradient-to-br from-pink-500 to-rose-600 rounded-xl flex items-center justify-center shadow-lg transform hover:scale-105 transition">
                            <i className="fas fa-hand-holding-heart text-white text-2xl"></i>
                        </div>
                        <div>
                            <h1 className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-pink-600 to-rose-600 dark:from-pink-400 dark:to-rose-400">MatriCare</h1>
                        </div>
                    </div>

                    <div className="flex items-center space-x-6">
                        <button
                            onClick={() => setCurrentView('dashboard')}
                            className={`hidden sm:block text-sm font-medium transition ${currentView === 'dashboard' ? 'text-pink-600 dark:text-pink-400' : 'text-gray-600 dark:text-gray-300 hover:text-pink-600 dark:hover:text-pink-400'}`}
                        >
                            <i className="fas fa-home mr-2"></i>Dashboard
                        </button>

                        <button
                            onClick={() => setDarkMode(!darkMode)}
                            className="p-2 text-gray-600 dark:text-gray-300 hover:text-pink-600 dark:hover:text-pink-400 transition transform hover:rotate-12"
                        >
                            <i className={`fas ${darkMode ? 'fa-sun' : 'fa-moon'} text-xl`}></i>
                        </button>

                        <div className="relative">
                            <button
                                onClick={() => setShowNotifications(!showNotifications)}
                                className="relative p-2 text-gray-600 dark:text-gray-300 hover:text-pink-600 dark:hover:text-pink-400 transition"
                            >
                                <i className="fas fa-bell text-xl"></i>
                                {alerts && alerts.length > 0 && (
                                    <span className="absolute top-0 right-0 w-5 h-5 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-bold animate-bounce">
                                        {alerts.length}
                                    </span>
                                )}
                            </button>
                        </div>
                    </div>

                    <div
                        className="flex items-center space-x-3 cursor-pointer hover:opacity-80 transition"
                        onClick={() => setCurrentView('doctorProfile')}
                    >
                        <div className="text-right hidden sm:block">
                            <p className="text-sm font-semibold text-gray-800 dark:text-white">{sessionStorage.getItem('doctorName') || 'Doctor'}</p>
                            <p className="text-xs text-gray-500 dark:text-gray-400">Obstetrician</p>
                        </div>
                        <img src={sessionStorage.getItem('doctorPhoto') || 'https://ui-avatars.com/api/?name=Doctor'} alt="Doctor" className="w-12 h-12 rounded-full border-2 border-pink-200 dark:border-pink-700 shadow-md" />
                    </div>
                    <button onClick={handleLogout} className="ml-2 text-gray-500 hover:text-red-500 transition" title="Logout">
                        <i className="fas fa-sign-out-alt"></i>
                    </button>
                </div>
            </div>
        </nav>
    );
}

// Doctor Profile View Component
function DoctorProfileView({ setCurrentView, showToast, alerts }) {
    const [myNotes, setMyNotes] = useState([]);

    useEffect(() => {
        // Aggregate notes from session storage (mock implementation)
        // In a real app, this would fetch from an API
        const allNotes = [];
        try {
            for (let i = 0; i < sessionStorage.length; i++) {
                const key = sessionStorage.key(i);
                if (key && key.startsWith('notes_')) {
                    const patientId = key.replace('notes_', '');
                    const item = sessionStorage.getItem(key);
                    if (item) {
                        try {
                            const notes = JSON.parse(item);
                            if (Array.isArray(notes)) {
                                notes.forEach(note => {
                                    allNotes.push({ ...note, patientId });
                                });
                            }
                        } catch (e) {
                            console.error(`Error parsing notes for ${key}:`, e);
                        }
                    }
                }
            }
        } catch (error) {
            console.error('Error accessing sessionStorage:', error);
        }
        setMyNotes(allNotes);
    }, []);

    return (
        <div className="p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto">
            <div className="bg-white dark:bg-gray-800 rounded-3xl p-8 shadow-xl mb-8 relative overflow-hidden">
                <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-pink-100 to-purple-100 dark:from-pink-900/20 dark:to-purple-900/20 rounded-full transform translate-x-1/3 -translate-y-1/3 opacity-50"></div>

                <div className="relative z-10 flex flex-col md:flex-row items-center md:items-start space-y-6 md:space-y-0 md:space-x-8">
                    <img src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&h=200&fit=crop" alt="Dr. Sarah" className="w-32 h-32 rounded-full border-4 border-white dark:border-gray-700 shadow-2xl" />
                    <div className="text-center md:text-left">
                        <h2 className="text-3xl font-bold text-gray-800 dark:text-white mb-2">Dr. Sarah Mitchell</h2>
                        <p className="text-lg text-pink-600 dark:text-pink-400 font-medium mb-4">Senior Obstetrician & Gynecologist</p>
                        <div className="flex flex-wrap justify-center md:justify-start gap-4">
                            <div className="bg-blue-50 dark:bg-blue-900/20 px-4 py-2 rounded-lg">
                                <span className="block text-2xl font-bold text-blue-600 dark:text-blue-400">12</span>
                                <span className="text-xs text-gray-600 dark:text-gray-400">Patients Today</span>
                            </div>
                            <div className="bg-green-50 dark:bg-green-900/20 px-4 py-2 rounded-lg">
                                <span className="block text-2xl font-bold text-green-600 dark:text-green-400">98%</span>
                                <span className="text-xs text-gray-600 dark:text-gray-400">Satisfaction</span>
                            </div>
                            <div className="bg-purple-50 dark:bg-purple-900/20 px-4 py-2 rounded-lg">
                                <span className="block text-2xl font-bold text-purple-600 dark:text-purple-400">5</span>
                                <span className="text-xs text-gray-600 dark:text-gray-400">Surgeries</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg">
                    <h3 className="text-xl font-bold text-gray-800 dark:text-white mb-6 flex items-center">
                        <i className="fas fa-tasks text-pink-500 mr-3"></i>
                        Urgent Tasks & Alerts
                    </h3>
                    <div className="space-y-4">
                        {alerts && alerts.length > 0 ? alerts.map((alert, index) => (
                            <div key={index} className="flex items-start space-x-4 p-4 bg-red-50 dark:bg-red-900/10 rounded-xl border border-red-100 dark:border-red-900/30">
                                <div className="bg-red-100 dark:bg-red-800 rounded-full p-2 flex-shrink-0">
                                    <i className="fas fa-exclamation text-red-600 dark:text-red-200"></i>
                                </div>
                                <div>
                                    <h4 className="font-semibold text-gray-800 dark:text-white">{alert.patient}</h4>
                                    <p className="text-sm text-gray-600 dark:text-gray-300 mt-1">{alert.message}</p>
                                    <button
                                        onClick={() => {
                                            // Logic to view alert
                                            showToast('Redirecting to alert...', 'info');
                                        }}
                                        className="text-xs font-bold text-red-600 dark:text-red-400 mt-2 hover:underline"
                                    >
                                        Review Now
                                    </button>
                                </div>
                            </div>
                        )) : (
                            <p className="text-gray-500 text-center py-4">No urgent tasks.</p>
                        )}
                    </div>
                </div>

                <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg">
                    <h3 className="text-xl font-bold text-gray-800 dark:text-white mb-6 flex items-center">
                        <i className="fas fa-sticky-note text-yellow-500 mr-3"></i>
                        My Saved Notes
                    </h3>
                    <div className="space-y-4 max-h-96 overflow-y-auto pr-2">
                        {myNotes.length > 0 ? myNotes.map((note, index) => (
                            <div key={index} className="p-4 bg-yellow-50 dark:bg-yellow-900/10 rounded-xl border border-yellow-100 dark:border-yellow-900/30 relative">
                                <div className="absolute top-4 right-4 text-xs text-gray-400">{note.time}</div>
                                <h4 className="font-bold text-gray-800 dark:text-white text-sm mb-1">Patient ID: {note.patientId}</h4>
                                <p className="text-sm text-gray-600 dark:text-gray-300 italic">"{note.note}"</p>
                            </div>
                        )) : (
                            <div className="text-center py-8">
                                <i className="fas fa-pen-alt text-gray-300 text-4xl mb-3"></i>
                                <p className="text-gray-500">You haven't saved any notes yet.</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}

// Dashboard View Component
function DashboardView({ setCurrentView, setSelectedPatient, setSelectedAlert, stats, patientHistory, maternalVitals, fetalMovementData, patients, alerts }) {
    return (
        <div className="flex flex-col xl:flex-row">
            <main className="flex-1 p-4 sm:p-6 lg:p-8">
                <StatCards stats={stats} />
                <ChartsSection patientHistory={patientHistory} maternalVitals={maternalVitals} />
                <FetalMovementChart data={fetalMovementData} />
                <PatientList setCurrentView={setCurrentView} setSelectedPatient={setSelectedPatient} patients={patients} />
            </main>
            <AlertsPanel setCurrentView={setCurrentView} setSelectedAlert={setSelectedAlert} alerts={alerts} />
        </div>
    );
}

// Stat Cards Component
function StatCards({ stats }) {
    if (!stats) return null;
    return (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
            {stats.map((card, index) => (
                <div key={index} className={`glass bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg hover:shadow-2xl transition transform hover:-translate-y-1 duration-300 ${card.border ? `border-l-4 ${card.border}` : ''}`}>
                    <div className="flex items-center justify-between mb-4">
                        <div className={`w-14 h-14 bg-${card.color}-100 dark:bg-${card.color}-900 rounded-xl flex items-center justify-center shadow-inner`}>
                            <i className={`fas ${card.icon} text-${card.color}-600 dark:text-${card.color}-400 text-2xl`}></i>
                        </div>
                        <span className={`text-3xl font-bold text-${card.color === 'blue' ? 'gray-800 dark:text-white' : card.color + '-600 dark:text-' + card.color + '-400'}`}>{card.value}</span>
                    </div>
                    <h3 className="text-gray-600 dark:text-gray-300 text-sm font-medium">{card.title}</h3>
                    <p className={`text-xs text-${card.trendColor}-600 dark:text-${card.trendColor}-400 mt-2`}>
                        <i className={`fas ${card.trendIcon}`}></i> {card.trend}
                    </p>
                </div>
            ))}
        </div>
    );
}

// Charts Section Component
function ChartsSection({ patientHistory, maternalVitals }) {
    const fetalHRRef = useRef(null);
    const chartInstance = useRef(null);

    useEffect(() => {
        if (fetalHRRef.current && patientHistory) {
            const ctx = fetalHRRef.current.getContext('2d');

            if (chartInstance.current) {
                chartInstance.current.destroy();
            }

            // Prepare datasets for the first 3 patients
            const datasets = [];
            const patientIds = Object.keys(patientHistory);
            const colors = ['rgb(34, 197, 94)', 'rgb(234, 179, 8)', 'rgb(239, 68, 68)']; // Green, Yellow, Red
            const labels = patientHistory[patientIds[0]]?.timestamps || [];

            patientIds.slice(0, 3).forEach((id, index) => {
                const history = patientHistory[id];
                datasets.push({
                    label: `Patient ${id} (BPM)`,
                    data: history.fetalHR,
                    borderColor: colors[index % colors.length],
                    backgroundColor: colors[index % colors.length].replace('rgb', 'rgba').replace(')', ', 0.1)'),
                    tension: 0.4,
                    fill: false,
                    pointRadius: 4,
                    pointHoverRadius: 6
                });
            });

            chartInstance.current = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: datasets
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: true, position: 'top' }
                    },
                    scales: {
                        y: { beginAtZero: false, min: 100, max: 200 }
                    }
                }
            });
        }

        return () => {
            if (chartInstance.current) {
                chartInstance.current.destroy();
            }
        };
    }, [patientHistory]);

    return (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
            <div className="lg:col-span-2 bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300 hover:shadow-xl">
                <div className="flex items-center justify-between mb-6">
                    <div>
                        <h3 className="text-lg font-bold text-gray-800 dark:text-white">Fetal Heart Rate Trends</h3>
                        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">Real-time monitoring across patients</p>
                    </div>
                    <div className="flex items-center space-x-2">
                        <span className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></span>
                        <span className="text-xs text-gray-600 dark:text-gray-300 font-medium">Live</span>
                    </div>
                </div>
                <div className="h-80 overflow-hidden">
                    <canvas ref={fetalHRRef}></canvas>
                </div>
            </div>

            <MaternalVitalsCard vitals={maternalVitals} />
        </div>
    );
}

// Maternal Vitals Card Component
function MaternalVitalsCard({ vitals }) {
    if (!vitals) return null;
    return (
        <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300 hover:shadow-xl">
            <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-6">Maternal Vitals Overview</h3>
            <div className="space-y-6">
                {vitals.map((vital, index) => (
                    <div key={index} className={`bg-gradient-to-r ${vital.gradient} rounded-xl p-4 transition-colors duration-300 transform hover:scale-105`}>
                        <div className="flex items-center justify-between mb-2">
                            <span className="text-sm text-gray-600 dark:text-gray-300 font-medium">{vital.title}</span>
                            <i className={`fas ${vital.icon} text-${vital.color}-500`}></i>
                        </div>
                        <p className="text-2xl font-bold text-gray-800 dark:text-white">{vital.value}</p>
                        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">{vital.unit}</p>
                    </div>
                ))}
            </div>
        </div>
    );
}

// Fetal Movement Chart Component
function FetalMovementChart({ data }) {
    const chartRef = useRef(null);
    const chartInstance = useRef(null);

    useEffect(() => {
        if (chartRef.current && data) {
            const ctx = chartRef.current.getContext('2d');

            if (chartInstance.current) {
                chartInstance.current.destroy();
            }

            chartInstance.current = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: 'Movement Count',
                        data: data.data,
                        backgroundColor: 'rgba(168, 85, 247, 0.7)',
                        borderColor: 'rgb(168, 85, 247)',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: true, position: 'top' }
                    },
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });
        }

        return () => {
            if (chartInstance.current) {
                chartInstance.current.destroy();
            }
        };
    }, [data]);

    return (
        <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg mb-8 transition-colors duration-300 hover:shadow-xl">
            <div className="flex items-center justify-between mb-6">
                <div>
                    <h3 className="text-lg font-bold text-gray-800 dark:text-white">Fetal Movement Count Trend</h3>
                    <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">Daily movement tracking</p>
                </div>
                <select className="text-sm border border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-pink-500">
                    <option>Last 7 days</option>
                    <option>Last 30 days</option>
                    <option>Last 3 months</option>
                </select>
            </div>
            <div className="h-64 overflow-hidden">
                <canvas ref={chartRef}></canvas>
            </div>
        </div>
    );
}

// Patient List Component
function PatientList({ setCurrentView, setSelectedPatient, patients }) {
    const handlePatientClick = (patient) => {
        setSelectedPatient(patient);
        setCurrentView('profile');
    };

    if (!patients) return null;

    return (
        <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300 hover:shadow-xl">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6 space-y-4 sm:space-y-0">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white">Patient List</h3>
                <div className="flex items-center space-x-3">
                    <div className="relative flex-1 sm:flex-none">
                        <input type="text" placeholder="Search patients..." className="w-full sm:w-64 pl-10 pr-4 py-2 border border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-500 text-sm" />
                        <i className="fas fa-search absolute left-3 top-3 text-gray-400 dark:text-gray-500"></i>
                    </div>
                    <button className="bg-pink-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-pink-700 transition shadow-md hover:shadow-lg">
                        <i className="fas fa-filter mr-2"></i>Filter
                    </button>
                </div>
            </div>

            <div className="overflow-x-auto">
                <table className="w-full">
                    <thead>
                        <tr className="border-b border-gray-200 dark:border-gray-700">
                            <th className="text-left py-3 px-4 text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Patient Name</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Pregnancy Week</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Risk Level</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Last Update</th>
                            <th className="text-left py-3 px-4 text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {patients.map((patient, index) => (
                            <tr key={index} className="border-b border-gray-100 dark:border-gray-700 hover:bg-pink-50 dark:hover:bg-gray-700 transition cursor-pointer group" onClick={() => handlePatientClick(patient)}>
                                <td className="py-4 px-4">
                                    <div className="flex items-center space-x-3">
                                        <img src={patient.image} alt="Patient" className="w-10 h-10 rounded-full transition transform group-hover:scale-110" />
                                        <div>
                                            <p className="font-semibold text-gray-800 dark:text-white text-sm">{patient.name}</p>
                                            <p className="text-xs text-gray-500 dark:text-gray-400">ID: {patient.id}</p>
                                        </div>
                                    </div>
                                </td>
                                <td className="py-4 px-4 text-sm text-gray-700 dark:text-gray-300">{patient.week}</td>
                                <td className="py-4 px-4">
                                    <span className={`px-3 py-1 bg-${patient.riskColor}-100 dark:bg-${patient.riskColor}-900 text-${patient.riskColor}-700 dark:text-${patient.riskColor}-300 rounded-full text-xs font-semibold`}>{patient.risk}</span>
                                </td>
                                <td className="py-4 px-4 text-sm text-gray-600 dark:text-gray-400">{patient.lastUpdate}</td>
                                <td className="py-4 px-4">
                                    <button className="text-pink-600 dark:text-pink-400 hover:text-pink-800 dark:hover:text-pink-300 text-sm font-medium">View Profile</button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

// Alerts Panel Component
function AlertsPanel({ setCurrentView, setSelectedAlert, alerts }) {
    const handleViewDetails = (alert) => {
        setSelectedAlert(alert);
        setCurrentView('alertDetail');
    };

    if (!alerts) return null;

    return (
        <aside className="w-full xl:w-80 bg-white dark:bg-gray-800 shadow-xl p-6 transition-colors duration-300 mt-6 xl:mt-0">
            <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white">Urgent Alerts</h3>
                <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
            </div>

            <div className="space-y-4">
                {alerts.map((alert, index) => (
                    <div key={index} className={`bg-${alert.color}-50 dark:bg-${alert.color}-900/20 border-l-4 border-${alert.color}-500 rounded-lg p-4 hover:shadow-md transition transform hover:-translate-x-1`}>
                        <div className="flex items-start justify-between mb-2">
                            <span className={`px-2 py-1 bg-${alert.color}-500 text-white text-xs font-bold rounded`}>{alert.type}</span>
                            <span className="text-xs text-gray-500 dark:text-gray-400">{alert.time}</span>
                        </div>
                        <p className="text-sm font-semibold text-gray-800 dark:text-white mb-1">{alert.patient}</p>
                        <p className="text-xs text-gray-700 dark:text-gray-300">{alert.message}</p>
                        <button
                            onClick={() => handleViewDetails(alert)}
                            className={`mt-3 text-xs text-${alert.color}-600 dark:text-${alert.color}-400 font-semibold hover:underline`}
                        >
                            View Details →
                        </button>
                    </div>
                ))}
            </div>

            <button className="w-full mt-6 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 py-3 rounded-lg text-sm font-medium hover:bg-gray-200 dark:hover:bg-gray-600 transition">
                View All Alerts
            </button>
        </aside>
    );
}

// Alert Detail View Component
function AlertDetailView({ setCurrentView, selectedAlert, showToast }) {
    if (!selectedAlert || !selectedAlert.fullDetails) {
        return (
            <div className="p-8 text-center">
                <p className="text-gray-600 dark:text-gray-400">No alert selected</p>
                <button onClick={() => setCurrentView('dashboard')} className="mt-4 text-pink-600 dark:text-pink-400 hover:underline">
                    Return to Dashboard
                </button>
            </div>
        );
    }

    const details = selectedAlert.fullDetails;

    const handleAction = (action) => {
        showToast(`${action} successfully`, 'success');
    };

    return (
        <div className="p-4 sm:p-6 lg:p-8">
            <button onClick={() => setCurrentView('dashboard')} className="mb-6 flex items-center space-x-2 text-pink-600 dark:text-pink-400 hover:text-pink-800 dark:hover:text-pink-300 transition">
                <i className="fas fa-arrow-left"></i>
                <span className="font-medium">Back to Dashboard</span>
            </button>

            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg mb-6 transition-colors duration-300">
                <div className="flex items-center justify-between mb-6">
                    <div className="flex items-center space-x-4">
                        <img src={details.patientImage} alt="Patient" className="w-20 h-20 rounded-full border-4 border-pink-200 dark:border-pink-700 shadow-md" />
                        <div>
                            <h2 className="text-2xl font-bold text-gray-800 dark:text-white">{details.patientName}</h2>
                            <p className="text-sm text-gray-500 dark:text-gray-400">Patient ID: {details.patientId}</p>
                            <p className="text-sm text-gray-600 dark:text-gray-300 mt-1">
                                <i className="fas fa-calendar mr-1"></i>{details.pregnancyWeek}
                            </p>
                        </div>
                    </div>
                    <div className={`bg-${selectedAlert.color}-100 dark:bg-${selectedAlert.color}-900/30 px-6 py-3 rounded-lg`}>
                        <p className="text-xs text-${selectedAlert.color}-600 dark:text-${selectedAlert.color}-400 font-semibold">Alert Severity</p>
                        <p className={`text-2xl font-bold text-${selectedAlert.color}-700 dark:text-${selectedAlert.color}-300`}>{details.severity}</p>
                    </div>
                </div>

                <div className={`bg-${selectedAlert.color}-50 dark:bg-${selectedAlert.color}-900/20 border-l-4 border-${selectedAlert.color}-500 rounded-lg p-4 mb-6`}>
                    <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-2">{details.alertType}</h3>
                    <p className="text-sm text-gray-700 dark:text-gray-300 mb-2">{details.description}</p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                        <i className="fas fa-clock mr-1"></i>Alert triggered: {details.timestamp}
                    </p>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300">
                    <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4 flex items-center">
                        <i className="fas fa-heartbeat text-red-500 mr-2"></i>
                        Vitals at Time of Alert
                    </h3>
                    <div className="space-y-3">
                        {Object.entries(details.vitalsAtAlert).map(([key, value], index) => (
                            <div key={index} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                                <span className="text-sm font-medium text-gray-600 dark:text-gray-300 capitalize">{key.replace(/([A-Z])/g, ' $1').trim()}</span>
                                <span className="text-sm font-bold text-gray-800 dark:text-white">{value}</span>
                            </div>
                        ))}
                    </div>
                </div>

                <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300">
                    <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4 flex items-center">
                        <i className="fas fa-clipboard-list text-blue-500 mr-2"></i>
                        Recommended Actions
                    </h3>
                    <div className="space-y-2">
                        {details.recommendedActions.map((action, index) => (
                            <div key={index} className="flex items-start space-x-3 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg hover:bg-blue-100 dark:hover:bg-blue-900/30 transition">
                                <i className="fas fa-check-circle text-blue-600 dark:text-blue-400 mt-1"></i>
                                <span className="text-sm text-gray-700 dark:text-gray-300">{action}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg mb-6 transition-colors duration-300">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4 flex items-center">
                    <i className="fas fa-history text-purple-500 mr-2"></i>
                    Alert Timeline
                </h3>
                <div className="space-y-4">
                    {details.alertHistory.length > 0 ? details.alertHistory.map((item, index) => (
                        <div key={index} className="flex items-start space-x-4">
                            <div className="flex flex-col items-center">
                                <div className={`w-4 h-4 rounded-full ${index === 0 ? 'bg-red-500' : 'bg-gray-400 dark:bg-gray-600'}`}></div>
                                {index < details.alertHistory.length - 1 && (
                                    <div className="w-0.5 h-12 bg-gray-300 dark:bg-gray-600"></div>
                                )}
                            </div>
                            <div className="flex-1 pb-4">
                                <p className="text-xs text-gray-500 dark:text-gray-400 font-semibold">{item.time}</p>
                                <p className="text-sm text-gray-700 dark:text-gray-300 mt-1">{item.event}</p>
                            </div>
                        </div>
                    )) : <p className="text-sm text-gray-500">No history available</p>}
                </div>
            </div>

            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4">Action Required</h3>
                <div className="flex flex-col sm:flex-row gap-4">
                    <button onClick={() => handleAction('Marked as Critical')} className="flex-1 bg-red-600 text-white py-3 px-6 rounded-lg font-semibold hover:bg-red-700 transition shadow-md">
                        <i className="fas fa-exclamation-triangle mr-2"></i>
                        Mark as Critical
                    </button>
                    <button onClick={() => handleAction('Assigned to Specialist')} className="flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg font-semibold hover:bg-blue-700 transition shadow-md">
                        <i className="fas fa-user-md mr-2"></i>
                        Assign to Specialist
                    </button>
                    <button onClick={() => handleAction('Alert Acknowledged')} className="flex-1 bg-green-600 text-white py-3 px-6 rounded-lg font-semibold hover:bg-green-700 transition shadow-md">
                        <i className="fas fa-check mr-2"></i>
                        Acknowledge Alert
                    </button>
                    <button onClick={() => handleAction('Note Added')} className="flex-1 bg-gray-600 text-white py-3 px-6 rounded-lg font-semibold hover:bg-gray-700 transition shadow-md">
                        <i className="fas fa-notes-medical mr-2"></i>
                        Add Notes
                    </button>
                </div>
            </div>
        </div>
    );
}

// Patient Profile View Component
function PatientProfileView({ setCurrentView, selectedPatient, patientHistory, showToast }) {
    const [firestorePatient, setFirestorePatient] = useState(null);
    const [appointments, setAppointments] = useState([]);
    const [symptoms, setSymptoms] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showAppointmentModal, setShowAppointmentModal] = useState(false);
    const [showSymptomModal, setShowSymptomModal] = useState(false);
    const history = selectedPatient && patientHistory ? patientHistory[selectedPatient.id] : null;

    // useEffect(() => {
    //     let unsubscribe = () => { };

    //     const setupRealtimeListeners = async () => {
    //         if (selectedPatient) {
    //             try {
    //                 console.log('Setting up real-time listeners for patient:', selectedPatient.name);

    //                 // First, get the patient data to get the document ID
    //                 const patientData = await window.FirebaseService.getPatientByName('Seema');

    //                 if (patientData) {
    //                     console.log('Patient found, setting up real-time listeners for ID:', patientData.id);
    //                     setFirestorePatient(patientData);

    //                     // Set up real-time listener for appointments and symptoms
    //                     unsubscribe = window.FirebaseService.listenToPatientUpdates(
    //                         patientData.id,
    //                         (update) => {
    //                             console.log('Real-time update received:', update.type, update.data);
    //                             if (update.type === 'appointments') {
    //                                 setAppointments(update.data);
    //                             } else if (update.type === 'symptoms') {
    //                                 setSymptoms(update.data);
    //                             }
    //                         }
    //                     );
    //                 } else {
    //                     console.log('No patient found in Firestore with name: Seema');
    //                 }
    //             } catch (error) {
    //                 console.error('Error setting up real-time listeners:', error);
    //                 showToast('Error loading patient data from Firestore', 'error');
    //             }
    //         }
    //         setLoading(false);
    //     };

    //     setupRealtimeListeners();

    //     // Cleanup function to unsubscribe when component unmounts
    //     return () => {
    //         console.log('Cleaning up real-time listeners');
    //         unsubscribe();
    //     };
    // }, [selectedPatient]);

    useEffect(() => {
        let unsubscribe = () => { };

        const setupRealtimeListeners = async () => {
            if (selectedPatient) {
                try {
                    console.log('Setting up real-time listeners for patient:', selectedPatient.name, 'ID:', selectedPatient.id);

                    // If the patient has a Firestore ID (which they should now), use it directly
                    // We no longer need to look up by name if we have the ID
                    const patientId = selectedPatient.id;

                    if (patientId) {
                        // Set up real-time listener for appointments and symptoms
                        unsubscribe = window.FirebaseService.listenToPatientUpdates(
                            patientId,
                            (update) => {
                                console.log('Real-time update received:', update.type, update.data);
                                if (update.type === 'appointments') {
                                    setAppointments(update.data || []);
                                } else if (update.type === 'symptoms') {
                                    setSymptoms(update.data || []);
                                }
                            }
                        );

                        // Also set initial data if available in selectedPatient (from DataService merge)
                        if (selectedPatient.appointments) setAppointments(selectedPatient.appointments);
                        if (selectedPatient.symptoms) setSymptoms(selectedPatient.symptoms);

                    } else {
                        console.log('No valid ID found for patient:', selectedPatient.name);
                    }

                } catch (error) {
                    console.error('Error setting up real-time listeners:', error);
                    showToast('Error loading patient data from Firestore', 'error');
                }
            }
            setLoading(false);
        };

        setupRealtimeListeners();

        // Cleanup function to unsubscribe when component unmounts
        return () => {
            console.log('Cleaning up real-time listeners');
            unsubscribe();
        };
    }, [selectedPatient]);


    return (
        <div className="p-4 sm:p-6 lg:p-8">
            <button onClick={() => setCurrentView('dashboard')} className="mb-6 flex items-center space-x-2 text-pink-600 dark:text-pink-400 hover:text-pink-800 dark:hover:text-pink-300 transition">
                <i className="fas fa-arrow-left"></i>
                <span className="font-medium">Back to Dashboard</span>
            </button>

            <ProfileHeader patient={selectedPatient} />

            {/* Appointments and Symptoms Section - Show if Firestore data is available */}
            {((appointments && appointments.length > 0) || (symptoms && symptoms.length > 0) || loading || firestorePatient) && (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
                    <AppointmentsSection
                        appointments={appointments || []}
                        loading={loading}
                        onAddAppointment={() => setShowAppointmentModal(true)}
                    />
                    <SymptomsSection
                        symptoms={symptoms || []}
                        loading={loading}
                        onAddSymptom={() => setShowSymptomModal(true)}
                    />
                </div>
            )}

            {/* Modals */}
            {showAppointmentModal && (
                <AppointmentModal
                    patientId={firestorePatient?.id}
                    onClose={() => setShowAppointmentModal(false)}
                    showToast={showToast}
                />
            )}
            {showSymptomModal && (
                <SymptomModal
                    patientId={firestorePatient?.id}
                    onClose={() => setShowSymptomModal(false)}
                    showToast={showToast}
                />
            )}

            <ProfileCharts history={history} />
            <DoctorNotes patientId={selectedPatient?.id} showToast={showToast} />
        </div>
    );
}

// Appointments Section Component
function AppointmentsSection({ appointments = [], loading, onAddAppointment }) {
    const formatDate = (timestamp) => {
        if (!timestamp) return 'N/A';
        try {
            // Handle Firestore Timestamp
            const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        } catch (error) {
            return 'Invalid Date';
        }
    };

    const getTypeIcon = (type) => {
        if (!type) return 'fa-calendar';
        const lowerType = type.toLowerCase();
        if (lowerType.includes('emergency')) return 'fa-ambulance';
        if (lowerType.includes('checkup')) return 'fa-stethoscope';
        return 'fa-calendar-check';
    };

    const getTypeColor = (type) => {
        if (!type) return 'blue';
        const lowerType = type.toLowerCase();
        if (lowerType.includes('emergency')) return 'red';
        if (lowerType.includes('routine')) return 'green';
        return 'yellow';
    };

    return (
        <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-800 dark:text-white flex items-center">
                    <i className="fas fa-calendar-alt text-blue-500 mr-3"></i>
                    Appointments
                </h3>
                {onAddAppointment && (
                    <button
                        onClick={onAddAppointment}
                        className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition flex items-center space-x-2"
                    >
                        <i className="fas fa-plus"></i>
                        <span>Add New</span>
                    </button>
                )}
            </div>

            {loading ? (
                <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500 mx-auto"></div>
                </div>
            ) : appointments.length > 0 ? (
                <div className="space-y-4 max-h-96 overflow-y-auto pr-2">
                    {appointments.map((appointment, index) => {
                        // Handle various field names for legacy data compatibility
                        const type = appointment.type || appointment.title || appointment.name || 'Appointment';
                        const date = appointment.date || appointment.timestamp || appointment.time;
                        const notes = appointment.notes || appointment.details || appointment.description;
                        const recommendedBy = appointment.recommendedBy || appointment.doctor || appointment.source;

                        const typeColor = getTypeColor(type);

                        return (
                            <div key={index} className={`p-4 bg-${typeColor}-50 dark:bg-${typeColor}-900/10 rounded-xl border border-${typeColor}-100 dark:border-${typeColor}-900/30`}>
                                <div className="flex items-start justify-between mb-2">
                                    <div className="flex items-center space-x-2">
                                        <i className={`fas ${getTypeIcon(type)} text-${typeColor}-600 dark:text-${typeColor}-400`}></i>
                                        <span className={`text-xs font-bold px-2 py-1 bg-${typeColor}-100 dark:bg-${typeColor}-800 text-${typeColor}-700 dark:text-${typeColor}-300 rounded capitalize`}>
                                            {type}
                                        </span>
                                    </div>
                                    <span className="text-xs text-gray-500 dark:text-gray-400">
                                        {formatDate(date)}
                                    </span>
                                </div>
                                {notes && (
                                    <p className="text-sm text-gray-700 dark:text-gray-300 mb-2">
                                        <strong>Notes:</strong> {notes}
                                    </p>
                                )}
                                {recommendedBy && (
                                    <p className="text-xs text-gray-600 dark:text-gray-400">
                                        <i className="fas fa-user-md mr-1"></i>
                                        Recommended by: {recommendedBy}
                                    </p>
                                )}
                            </div>
                        );
                    })}
                </div>
            ) : (
                <div className="text-center py-8">
                    <i className="fas fa-calendar-times text-gray-300 dark:text-gray-600 text-4xl mb-3"></i>
                    <p className="text-gray-500 dark:text-gray-400">No appointments scheduled</p>
                </div>
            )}
        </div>
    );
}

// Symptoms Section Component
function SymptomsSection({ symptoms = [], loading, onAddSymptom }) {
    const formatDate = (timestamp) => {
        if (!timestamp) return 'N/A';
        try {
            const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric'
            });
        } catch (error) {
            return 'Invalid Date';
        }
    };

    const getSeverityColor = (severity) => {
        if (!severity) return 'gray';
        const lowerSeverity = severity.toLowerCase();
        if (lowerSeverity.includes('high') || lowerSeverity.includes('severe')) return 'red';
        if (lowerSeverity.includes('medium') || lowerSeverity.includes('moderate')) return 'yellow';
        return 'green';
    };

    return (
        <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-800 dark:text-white flex items-center">
                    <i className="fas fa-notes-medical text-purple-500 mr-3"></i>
                    Symptoms
                </h3>
                {onAddSymptom && (
                    <button
                        onClick={onAddSymptom}
                        className="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition flex items-center space-x-2"
                    >
                        <i className="fas fa-plus"></i>
                        <span>Add New</span>
                    </button>
                )}
            </div>

            {loading ? (
                <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-purple-500 mx-auto"></div>
                </div>
            ) : symptoms.length > 0 ? (
                <div className="space-y-4 max-h-96 overflow-y-auto pr-2">
                    {symptoms.map((symptom, index) => {
                        // Handle various field names for legacy data compatibility
                        const severity = symptom.severity || symptom.level || symptom.status || 'low';
                        const name = symptom.symptom || symptom.name || symptom.title || symptom.description || 'Unknown Symptom';
                        const notes = symptom.notes || symptom.details || symptom.comment || '';

                        const severityColor = getSeverityColor(severity);

                        return (
                            <div key={index} className={`p-4 bg-${severityColor}-50 dark:bg-${severityColor}-900/10 rounded-xl border border-${severityColor}-100 dark:border-${severityColor}-900/30`}>
                                <div className="flex items-start justify-between mb-2">
                                    <span className={`text-xs font-bold px-2 py-1 bg-${severityColor}-100 dark:bg-${severityColor}-800 text-${severityColor}-700 dark:text-${severityColor}-300 rounded capitalize`}>
                                        {severity}
                                    </span>
                                    <span className="text-xs text-gray-500 dark:text-gray-400">
                                        {formatDate(symptom.date || symptom.timestamp || symptom.created_at)}
                                    </span>
                                </div>
                                <p className="text-sm text-gray-700 dark:text-gray-300 font-medium mb-1">
                                    {name}
                                </p>
                                {notes && (
                                    <p className="text-xs text-gray-600 dark:text-gray-400 mt-2">
                                        {notes}
                                    </p>
                                )}
                            </div>
                        );
                    })}
                </div>
            ) : (
                <div className="text-center py-8">
                    <i className="fas fa-heartbeat text-gray-300 dark:text-gray-600 text-4xl mb-3"></i>
                    <p className="text-gray-500 dark:text-gray-400">No symptoms recorded</p>
                </div>
            )}
        </div>
    );
}


// Profile Header Component
function ProfileHeader({ patient }) {
    return (
        <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg mb-6 transition-colors duration-300">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between space-y-4 sm:space-y-0">
                <div className="flex items-center space-x-4">
                    <img src={patient?.image || 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop'} alt="Patient" className="w-20 h-20 rounded-full border-4 border-pink-200 dark:border-pink-700 shadow-md" />
                    <div>
                        <h2 className="text-2xl font-bold text-gray-800 dark:text-white">{patient?.name || 'Emma Johnson'}</h2>
                        <p className="text-sm text-gray-500 dark:text-gray-400">Patient ID: {patient?.id || 'PT-2847'}</p>
                        <div className="flex items-center space-x-4 mt-2">
                            <span className="text-sm text-gray-600 dark:text-gray-300"><i className="fas fa-calendar mr-1"></i>{patient?.week || '32 weeks pregnant'}</span>
                            <span className="text-sm text-gray-600 dark:text-gray-300"><i className="fas fa-birthday-cake mr-1"></i>28 years old</span>
                        </div>
                    </div>
                </div>
                <div className="flex items-center space-x-3">
                    <div className="bg-red-100 dark:bg-red-900/30 px-4 py-2 rounded-lg">
                        <p className="text-xs text-red-600 dark:text-red-400 font-semibold">Risk Level</p>
                        <p className="text-lg font-bold text-red-700 dark:text-red-300">{patient?.risk || 'High Risk'}</p>
                    </div>
                    <div className="bg-purple-100 dark:bg-purple-900/30 px-4 py-2 rounded-lg">
                        <p className="text-xs text-purple-600 dark:text-purple-400 font-semibold">AI Risk Score</p>
                        <p className="text-lg font-bold text-purple-700 dark:text-purple-300">7.8/10</p>
                    </div>
                </div>
            </div>
        </div>
    );
}

// Profile Charts Component
function ProfileCharts({ history }) {
    const fetalHRRef = useRef(null);
    const maternalHRRef = useRef(null);
    const bpRef = useRef(null);
    const movementRef = useRef(null);

    useEffect(() => {
        if (!history) return;

        const charts = [];
        const labels = history.timestamps;

        if (fetalHRRef.current) {
            charts.push(new Chart(fetalHRRef.current.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Fetal HR (bpm)',
                        data: history.fetalHR,
                        borderColor: 'rgb(239, 68, 68)',
                        backgroundColor: 'rgba(239, 68, 68, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: false, min: 100, max: 200 } }
                }
            }));
        }

        if (maternalHRRef.current) {
            charts.push(new Chart(maternalHRRef.current.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Maternal HR (bpm)',
                        data: history.maternalHR,
                        borderColor: 'rgb(168, 85, 247)',
                        backgroundColor: 'rgba(168, 85, 247, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: false, min: 60, max: 130 } }
                }
            }));
        }

        if (bpRef.current) {
            // Parse BP "120/80" -> [120, 80]
            const systolic = history.bp.map(v => (typeof v === 'string' && v.includes('/')) ? parseInt(v.split('/')[0]) : 120);
            const diastolic = history.bp.map(v => (typeof v === 'string' && v.includes('/')) ? parseInt(v.split('/')[1]) : 80);

            charts.push(new Chart(bpRef.current.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Systolic',
                        data: systolic,
                        borderColor: 'rgb(239, 68, 68)',
                        tension: 0.4
                    }, {
                        label: 'Diastolic',
                        data: diastolic,
                        borderColor: 'rgb(59, 130, 246)',
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: true, position: 'top' } },
                    scales: { y: { beginAtZero: false, min: 50, max: 180 } }
                }
            }));
        }

        if (movementRef.current) {
            charts.push(new Chart(movementRef.current.getContext('2d'), {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Movement Count',
                        data: history.movement,
                        backgroundColor: 'rgba(34, 197, 94, 0.7)',
                        borderColor: 'rgb(34, 197, 94)',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true } }
                }
            }));
        }

        return () => {
            charts.forEach(chart => chart.destroy());
        };
    }, [history]);

    if (!history) {
        return (
            <div className="p-8 text-center text-gray-500">
                <p>Waiting for real-time data...</p>
            </div>
        );
    }

    return (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4">Fetal Heart Rate Trend</h3>
                <div className="h-64 overflow-hidden">
                    <canvas ref={fetalHRRef}></canvas>
                </div>
            </div>

            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4">Maternal Heart Rate Trend</h3>
                <div className="h-64 overflow-hidden">
                    <canvas ref={maternalHRRef}></canvas>
                </div>
            </div>

            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4">Blood Pressure Monitoring</h3>
                <div className="h-64 overflow-hidden">
                    <canvas ref={bpRef}></canvas>
                </div>
            </div>

            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4">Fetal Movement Count</h3>
                <div className="h-64 overflow-hidden">
                    <canvas ref={movementRef}></canvas>
                </div>
            </div>
        </div>
    );
}

// Doctor Notes Component
function DoctorNotes({ patientId, showToast }) {
    const [notes, setNotes] = useState([]);
    const [newNote, setNewNote] = useState('');

    // Load notes from session storage on mount
    useEffect(() => {
        try {
            const savedNotes = sessionStorage.getItem(`notes_${patientId}`);
            if (savedNotes) {
                setNotes(JSON.parse(savedNotes));
            } else {
                // Default mock notes
                setNotes([
                    {
                        doctor: 'Dr. Sarah Mitchell',
                        image: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=40&h=40&fit=crop',
                        time: 'Today at 10:30 AM',
                        note: 'Patient showing signs of preeclampsia. Recommended immediate monitoring.',
                        color: 'blue'
                    }
                ]);
            }
        } catch (error) {
            console.error('Error parsing notes:', error);
            setNotes([]);
        }
    }, [patientId]);

    const handleSaveNote = () => {
        if (!newNote.trim()) return;

        const note = {
            doctor: 'Dr. Sarah Mitchell', // Current user
            image: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=40&h=40&fit=crop',
            time: 'Just now',
            note: newNote,
            color: 'blue'
        };

        const updatedNotes = [note, ...notes];
        setNotes(updatedNotes);
        sessionStorage.setItem(`notes_${patientId}`, JSON.stringify(updatedNotes));
        setNewNote('');
        showToast('Note saved successfully', 'success');
    };

    return (
        <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg transition-colors duration-300">
            <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-bold text-gray-800 dark:text-white">Doctor Notes & Observations</h3>
            </div>

            <div className="space-y-4 mb-6">
                {notes.map((note, index) => (
                    <div key={index} className={`border-l-4 border-${note.color}-500 bg-${note.color}-50 dark:bg-${note.color}-900/20 p-4 rounded-lg transition-colors duration-300`}>
                        <div className="flex items-start justify-between mb-2">
                            <div className="flex items-center space-x-2">
                                <img src={note.image} alt="Doctor" className="w-8 h-8 rounded-full" />
                                <div>
                                    <p className="text-sm font-semibold text-gray-800 dark:text-white">{note.doctor}</p>
                                    <p className="text-xs text-gray-500 dark:text-gray-400">{note.time}</p>
                                </div>
                            </div>
                        </div>
                        <p className="text-sm text-gray-700 dark:text-gray-300">{note.note}</p>
                    </div>
                ))}
            </div>

            <div className="mt-6">
                <textarea
                    className="w-full border border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-lg p-4 focus:outline-none focus:ring-2 focus:ring-pink-500 text-sm transition-colors duration-300"
                    rows="4"
                    placeholder="Add your observations and notes here..."
                    value={newNote}
                    onChange={(e) => setNewNote(e.target.value)}
                ></textarea>
                <div className="flex justify-end mt-3">
                    <button
                        onClick={handleSaveNote}
                        className="bg-pink-600 text-white px-6 py-2 rounded-lg text-sm font-medium hover:bg-pink-700 transition shadow-md"
                    >
                        Save Note
                    </button>
                </div>
            </div>
        </div>
    );
}

// Appointment Modal Component
function AppointmentModal({ patientId, onClose, showToast }) {
    const [formData, setFormData] = useState({
        date: '',
        type: 'routine checkup',
        notes: '',
        recommendedBy: 'doctor'
    });
    const [submitting, setSubmitting] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!patientId) {
            showToast('Patient ID not found', 'error');
            return;
        }

        setSubmitting(true);
        const success = await window.FirebaseService.addAppointment(patientId, formData);

        if (success) {
            showToast('Appointment added successfully', 'success');
            onClose();
        } else {
            showToast('Failed to add appointment', 'error');
        }
        setSubmitting(false);
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 max-w-md w-full shadow-2xl">
                <div className="flex items-center justify-between mb-6">
                    <h3 className="text-xl font-bold text-gray-800 dark:text-white">Add New Appointment</h3>
                    <button onClick={onClose} className="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300">
                        <i className="fas fa-times text-xl"></i>
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Date & Time
                        </label>
                        <input
                            type="datetime-local"
                            required
                            value={formData.date}
                            onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Type
                        </label>
                        <select
                            value={formData.type}
                            onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
                        >
                            <option value="routine checkup">Routine Checkup</option>
                            <option value="emergency">Emergency</option>
                            <option value="mid emergency">Mid Emergency</option>
                            <option value="follow-up">Follow-up</option>
                            <option value="consultation">Consultation</option>
                        </select>
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Notes
                        </label>
                        <textarea
                            value={formData.notes}
                            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                            rows="3"
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
                            placeholder="Add any notes..."
                        ></textarea>
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Recommended By
                        </label>
                        <input
                            type="text"
                            value={formData.recommendedBy}
                            onChange={(e) => setFormData({ ...formData, recommendedBy: e.target.value })}
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
                            placeholder="doctor, manual, etc."
                        />
                    </div>

                    <div className="flex space-x-3 pt-4">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={submitting}
                            className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {submitting ? 'Adding...' : 'Add Appointment'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

// Symptom Modal Component
function SymptomModal({ patientId, onClose, showToast }) {
    const [formData, setFormData] = useState({
        date: new Date().toISOString().split('T')[0],
        symptom: '',
        severity: 'low',
        notes: ''
    });
    const [submitting, setSubmitting] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!patientId) {
            showToast('Patient ID not found', 'error');
            return;
        }

        setSubmitting(true);
        const success = await window.FirebaseService.addSymptom(patientId, formData);

        if (success) {
            showToast('Symptom added successfully', 'success');
            onClose();
        } else {
            showToast('Failed to add symptom', 'error');
        }
        setSubmitting(false);
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 max-w-md w-full shadow-2xl">
                <div className="flex items-center justify-between mb-6">
                    <h3 className="text-xl font-bold text-gray-800 dark:text-white">Add New Symptom</h3>
                    <button onClick={onClose} className="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300">
                        <i className="fas fa-times text-xl"></i>
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Date
                        </label>
                        <input
                            type="date"
                            required
                            value={formData.date}
                            onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-purple-500 dark:bg-gray-700 dark:text-white"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Symptom Description
                        </label>
                        <input
                            type="text"
                            required
                            value={formData.symptom}
                            onChange={(e) => setFormData({ ...formData, symptom: e.target.value })}
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-purple-500 dark:bg-gray-700 dark:text-white"
                            placeholder="e.g., headache, nausea, fatigue"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Severity
                        </label>
                        <select
                            value={formData.severity}
                            onChange={(e) => setFormData({ ...formData, severity: e.target.value })}
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-purple-500 dark:bg-gray-700 dark:text-white"
                        >
                            <option value="low">Low</option>
                            <option value="medium">Medium</option>
                            <option value="moderate">Moderate</option>
                            <option value="high">High</option>
                            <option value="severe">Severe</option>
                        </select>
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Additional Notes
                        </label>
                        <textarea
                            value={formData.notes}
                            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                            rows="3"
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-purple-500 dark:bg-gray-700 dark:text-white"
                            placeholder="Any additional details..."
                        ></textarea>
                    </div>

                    <div className="flex space-x-3 pt-4">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={submitting}
                            className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {submitting ? 'Adding...' : 'Add Symptom'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

// Render App
ReactDOM.render(<App />, document.getElementById('root'));
