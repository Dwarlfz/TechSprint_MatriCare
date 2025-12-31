// // Data Service - Fetches from Python Backend

// const API_URL = 'http://localhost:5000/api/data';

// const DataService = {
//     // Fetch data from the Python backend
//     fetchData: async () => {
//         try {
//             const response = await fetch(API_URL);
//             if (!response.ok) {
//                 throw new Error('Network response was not ok');
//             }
//             const rawData = await response.json();
//             return DataService.processData(rawData);
//         } catch (error) {
//             console.error('Error fetching data:', error);
//             // Return empty structure or cached data on error to prevent crash
//             return DataService.getEmptyData();
//         }
//     },

//     // Process raw CSV JSON into Dashboard format
//     processData: (rawData) => {
//         // Generate Patients List
//         const patients = rawData.map((row, index) => {
//             const isHighRisk = String(row.label) === '1';
//             const risk = isHighRisk ? 'High Risk' : 'Low Risk';
//             const riskColor = isHighRisk ? 'red' : 'green';

//             return {
//                 name: `Patient ${index + 100}`,
//                 id: `PT-${2000 + index}`,
//                 week: `${row.pregnancyWeeks} weeks`,
//                 risk: risk,
//                 riskColor: riskColor,
//                 lastUpdate: 'Just now',
//                 image: `https://ui-avatars.com/api/?name=Patient+${index}&background=random`,
//                 // Store raw data for detailed view
//                 vitals: {
//                     fetalHR: row.fetalHeartRate,
//                     maternalHR: row.maternalHeartRate,
//                     bp: row.bloodPressure,
//                     movement: row.fetalMovement
//                 }
//             };
//         });

//         // Calculate Stats
//         const totalPatients = patients.length;
//         const highRiskCount = patients.filter(p => p.risk === 'High Risk').length;
//         const lowRiskCount = patients.filter(p => p.risk === 'Low Risk').length;

//         return {
//             stats: [
//                 { title: 'Total Patients', value: totalPatients.toString(), icon: 'fa-users', color: 'blue', trend: 'Live Data', trendIcon: 'fa-sync', trendColor: 'blue' },
//                 { title: 'High-Risk Patients', value: highRiskCount.toString(), icon: 'fa-exclamation-triangle', color: 'red', trend: `${totalPatients > 0 ? ((highRiskCount / totalPatients) * 100).toFixed(1) : 0}% of total`, trendIcon: 'fa-chart-pie', trendColor: 'red', border: 'border-red-500' },
//                 { title: 'Low-Risk Patients', value: lowRiskCount.toString(), icon: 'fa-check-circle', color: 'green', trend: 'Stable condition', trendIcon: 'fa-smile', trendColor: 'green', border: 'border-green-500' },
//                 { title: 'Active Alerts', value: '5', icon: 'fa-bell', color: 'purple', trend: 'Last 24 hours', trendIcon: 'fa-clock', trendColor: 'purple' }
//             ],
//             fetalHR: {
//                 labels: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '24:00'],
//                 data: [140, 142, 138, 145, 130, 128, 140] // Placeholder trend as CSV is snapshot data
//             },
//             maternalVitals: [
//                 { title: 'Avg Blood Pressure', value: '120/80', unit: 'mmHg', icon: 'fa-heartbeat', color: 'red', gradient: 'from-red-50 to-pink-50 dark:from-red-900/20 dark:to-pink-900/20' },
//                 { title: 'Avg SpO2 Level', value: '98%', unit: 'Oxygen saturation', icon: 'fa-lungs', color: 'blue', gradient: 'from-blue-50 to-cyan-50 dark:from-blue-900/20 dark:to-cyan-900/20' },
//                 { title: 'Avg Heart Rate', value: '85 bpm', unit: 'Normal range', icon: 'fa-heart', color: 'purple', gradient: 'from-purple-50 to-indigo-50 dark:from-purple-900/20 dark:to-indigo-900/20' }
//             ],
//             fetalMovement: {
//                 labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
//                 data: [45, 52, 48, 55, 42, 50, 47]
//             },
//             patients: patients.slice(0, 50), // Limit to 50 for performance
//             alerts: [
//                 {
//                     id: 1,
//                     type: 'CRITICAL',
//                     color: 'red',
//                     patient: 'Patient 101 - PT-2001',
//                     message: 'High Fetal Heart Rate detected (187 bpm)',
//                     time: '10 min ago',
//                     fullDetails: {
//                         patientName: 'Patient 101',
//                         patientId: 'PT-2001',
//                         patientImage: 'https://ui-avatars.com/api/?name=Patient+1',
//                         pregnancyWeek: '29 weeks',
//                         alertType: 'Critical Fetal Heart Rate',
//                         severity: 'CRITICAL',
//                         timestamp: '2024-01-15 14:32:00',
//                         description: 'Abnormally high fetal heart rate detected during routine scan.',
//                         vitalsAtAlert: {
//                             fetalHR: '187 bpm',
//                             maternalHR: '93 bpm',
//                             bloodPressure: '127/85 mmHg',
//                             spo2: '97%'
//                         },
//                         recommendedActions: [
//                             'Immediate ultrasound examination',
//                             'Continuous fetal monitoring',
//                             'Notify on-call obstetrician'
//                         ],
//                         alertHistory: []
//                     }
//                 }
//             ]
//         };
//     },

//     getEmptyData: () => {
//         return {
//             stats: [],
//             fetalHR: { labels: [], data: [] },
//             maternalVitals: [],
//             fetalMovement: { labels: [], data: [] },
//             patients: [],
//             alerts: []
//         };
//     }
// };

// // Make it available globally
// window.DataService = DataService;

// Data Service - Fetches from Python Backend

const API_URL = 'http://localhost:5000/api/data';

const DataService = {
    // Fetch data from the Python backend and Firestore
    fetchData: async () => {
        try {
            // 1. Fetch Vitals from Python Backend
            const response = await fetch(API_URL);
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            const rawData = await response.json();

            // 2. Fetch Patients from Firestore
            let firestorePatients = [];
            if (window.FirebaseService) {
                firestorePatients = await window.FirebaseService.getAllPatients();
            }

            // 3. Process and Merge
            return DataService.processData(rawData, firestorePatients);
        } catch (error) {
            console.error('Error fetching data:', error);
            return DataService.getEmptyData();
        }
    },

    // Process raw CSV JSON and Firestore data into Dashboard format
    processData: (rawData, firestorePatients) => {
        // Default mock patients if Firestore is empty
        let patientsList = firestorePatients;

        if (!patientsList || patientsList.length === 0) {
            // Fallback if no Firestore data
            patientsList = [
                { name: "Seema", id: "default-seema", risk: "High Risk" },
                { name: "Patient 2", id: "default-p2", risk: "Low Risk" },
                { name: "Patient 3", id: "default-p3", risk: "Low Risk" }
            ];
        }

        // Ensure we have at least 3 patients to map to our 3 data streams
        // If Firestore returned fewer than 3, we might need to recycle or handle gracefully
        // For now, we'll map available patients to available data rows

        const patients = patientsList.map((patient, index) => {
            // Get corresponding vitals row (cycle through rawData if more patients than rows)
            const dataRow = rawData[index % rawData.length];

            // Determine Risk
            // User Request: Seema = High Risk, Others = Low/Medium
            const isSeema = patient.name.toLowerCase().includes('seema');
            const risk = isSeema ? 'High Risk' : 'Low Risk';
            const riskColor = isSeema ? 'red' : 'green';

            // Construct Patient Object
            return {
                ...patient, // properties from Firestore (id, name, etc.)

                // Dashboard display properties
                week: `${dataRow.pregnancyWeeks} weeks`,
                risk: risk,
                riskColor: riskColor,
                lastUpdate: 'Just now',
                image: patient.photoURL || `https://ui-avatars.com/api/?name=${encodeURIComponent(patient.name)}&background=random`,

                // Real-time Vitals from Python Backend
                vitals: {
                    fetalHR: dataRow.fetalHeartRate,
                    maternalHR: dataRow.maternalHeartRate,
                    bp: dataRow.bloodPressure,
                    movement: dataRow.fetalMovement
                },

                // Firestore data (appointments/symptoms) should already be in 'patient' object
                // if fetched via getAllPatients. If not, they will be loaded by PatientProfileView.
                // We ensure they are arrays to prevent errors.
                appointments: patient.appointments || [],
                symptoms: patient.symptoms || []
            };
        });

        // Sort so Seema is always first (optional, but good for visibility)
        patients.sort((a, b) => {
            if (a.name.toLowerCase().includes('seema')) return -1;
            if (b.name.toLowerCase().includes('seema')) return 1;
            return 0;
        });

        // ------------------------------
        //  STATS
        // ------------------------------

        const totalPatients = patients.length;
        const highRiskCount = patients.filter(p => p.risk === 'High Risk').length;
        const lowRiskCount = patients.filter(p => p.risk === 'Low Risk').length;

        // Find Seema for the Alert
        const seema = patients.find(p => p.name.toLowerCase().includes('seema')) || patients[0];

        return {
            stats: [
                { title: 'Total Patients', value: totalPatients.toString(), icon: 'fa-users', color: 'blue', trend: 'Live Data', trendIcon: 'fa-sync', trendColor: 'blue' },
                { title: 'High-Risk Patients', value: highRiskCount.toString(), icon: 'fa-exclamation-triangle', color: 'red', trend: `${totalPatients > 0 ? ((highRiskCount / totalPatients) * 100).toFixed(1) : 0}% of total`, trendIcon: 'fa-chart-pie', trendColor: 'red', border: 'border-red-500' },
                { title: 'Low-Risk Patients', value: lowRiskCount.toString(), icon: 'fa-check-circle', color: 'green', trend: 'Stable condition', trendIcon: 'fa-smile', trendColor: 'green', border: 'border-green-500' },
                { title: 'Active Alerts', value: '1', icon: 'fa-bell', color: 'purple', trend: 'Last 24 hours', trendIcon: 'fa-clock', trendColor: 'purple' }
            ],

            fetalHR: {
                labels: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '24:00'],
                data: [140, 142, 138, 145, 130, 128, 140]
            },

            maternalVitals: [
                { title: 'Avg Blood Pressure', value: '120/80', unit: 'mmHg', icon: 'fa-heartbeat', color: 'red', gradient: 'from-red-50 to-pink-50 dark:from-red-900/20 dark:to-pink-900/20' },
                { title: 'Avg SpO2 Level', value: '98%', unit: 'Oxygen saturation', icon: 'fa-lungs', color: 'blue', gradient: 'from-blue-50 to-cyan-50 dark:from-blue-900/20 dark:to-cyan-900/20' },
                { title: 'Avg Heart Rate', value: '85 bpm', unit: 'Normal range', icon: 'fa-heart', color: 'purple', gradient: 'from-purple-50 to-indigo-50 dark:from-purple-900/20 dark:to-indigo-900/20' }
            ],

            fetalMovement: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                data: [45, 52, 48, 55, 42, 50, 47]
            },

            patients: patients,

            alerts: [
                {
                    id: 1,
                    type: 'CRITICAL',
                    color: 'red',
                    patient: `${seema.name} - ${seema.id}`,
                    message: 'High Fetal Heart Rate detected (187 bpm)',
                    time: '10 min ago',
                    fullDetails: {
                        patientName: seema.name,
                        patientId: seema.id,
                        patientImage: seema.image,
                        pregnancyWeek: seema.week,
                        alertType: 'Critical Fetal Heart Rate',
                        severity: 'CRITICAL',
                        timestamp: '2024-01-15 14:32:00',
                        description: 'Abnormally high fetal heart rate detected during routine scan.',
                        vitalsAtAlert: {
                            fetalHR: '187 bpm',
                            maternalHR: '93 bpm',
                            bloodPressure: '127/85 mmHg',
                            spo2: '97%'
                        },
                        recommendedActions: [
                            'Immediate ultrasound examination',
                            'Continuous fetal monitoring',
                            'Notify on-call obstetrician'
                        ],
                        alertHistory: []
                    }
                }
            ]
        };
    },

    getEmptyData: () => {
        return {
            stats: [],
            fetalHR: { labels: [], data: [] },
            maternalVitals: [],
            fetalMovement: { labels: [], data: [] },
            patients: [],
            alerts: []
        };
    }
};

// Make it available globally
window.DataService = DataService;
