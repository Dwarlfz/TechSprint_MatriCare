// Firebase Service - Handles all Firestore operations
// Firebase v9+ modular SDK

// Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyCNp7yN0l1R2v-Ecu4lE-yGVCUAIcw5wJ0",
    authDomain: "matricare-c5825.firebaseapp.com",
    databaseURL: "https://matricare-c5825-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "matricare-c5825",
    storageBucket: "matricare-c5825.firebasestorage.app",
    messagingSenderId: "348011515531",
    appId: "1:348011515531:web:81bc3a23454a38c69a4e8e",
    measurementId: "G-6VTDVM59W0"
};

// Initialize Firebase (will be done after SDK loads)
let app;
let db;

// Initialize Firebase after SDK is loaded
function initializeFirebase() {
    if (typeof firebase === 'undefined') {
        console.error('Firebase SDK not loaded');
        return false;
    }

    try {
        app = firebase.initializeApp(firebaseConfig);
        db = firebase.firestore();
        console.log('Firebase initialized successfully');
        return true;
    } catch (error) {
        console.error('Error initializing Firebase:', error);
        return false;
    }
}

const FirebaseService = {
    /**
     * Get patient by name (e.g., "Seema")
     * @param {string} name - Patient name
     * @returns {Promise<Object>} Patient data with appointments and symptoms
     */
    getPatientByName: async (name) => {
        try {
            if (!db) {
                console.error('Firestore not initialized');
                return null;
            }

            // Query users collection for patient with matching name
            const usersRef = db.collection('users');
            const querySnapshot = await usersRef.where('name', '==', name).get();

            if (querySnapshot.empty) {
                console.log(`No patient found with name: ${name}`);
                return null;
            }

            // Get first matching patient
            const patientDoc = querySnapshot.docs[0];
            const patientData = {
                id: patientDoc.id,
                ...patientDoc.data()
            };

            // Fetch appointments subcollection
            const appointmentsSnapshot = await patientDoc.ref.collection('appointments').get();
            patientData.appointments = appointmentsSnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));

            // Fetch symptoms subcollection
            const symptomsSnapshot = await patientDoc.ref.collection('symptoms').get();
            patientData.symptoms = symptomsSnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));

            console.log('Patient data fetched:', patientData);
            return patientData;
        } catch (error) {
            console.error('Error fetching patient:', error);
            return null;
            return null;
        }
    },

    /**
     * Listen to real-time updates for a patient's appointments and symptoms
     * @param {string} patientId - Patient document ID
     * @param {Function} callback - Callback function to handle updates
     * @returns {Function} Unsubscribe function
     */
    listenToPatientUpdates: (patientId, callback) => {
        try {
            if (!db) {
                console.error('Firestore not initialized');
                return () => { };
            }

            const patientRef = db.collection('users').doc(patientId);

            // Listen to appointments
            const unsubscribeAppointments = patientRef.collection('appointments')
                .onSnapshot((snapshot) => {
                    const appointments = snapshot.docs.map(doc => ({
                        id: doc.id,
                        ...doc.data()
                    }));
                    callback({ type: 'appointments', data: appointments });
                });

            // Listen to symptoms
            const unsubscribeSymptoms = patientRef.collection('symptoms')
                .onSnapshot((snapshot) => {
                    const symptoms = snapshot.docs.map(doc => ({
                        id: doc.id,
                        ...doc.data()
                    }));
                    callback({ type: 'symptoms', data: symptoms });
                });

            // Return combined unsubscribe function
            return () => {
                unsubscribeAppointments();
                unsubscribeSymptoms();
            };
        } catch (error) {
            console.error('Error setting up real-time listener:', error);
            return () => { };
        }
    },

    /**
     * Get all patients from users collection
     * @returns {Promise<Array>} Array of patient data
     */
    /**
     * Get all patients from users collection including their subcollections
     * @returns {Promise<Array>} Array of patient data
     */
    getAllPatients: async () => {
        try {
            if (!db) {
                console.error('Firestore not initialized');
                return [];
            }

            const usersRef = db.collection('users');
            const querySnapshot = await usersRef.get();

            // Map patients and fetch their subcollections in parallel
            const patientsPromises = querySnapshot.docs.map(async (doc) => {
                const patientData = {
                    id: doc.id,
                    ...doc.data()
                };

                try {
                    // Fetch appointments
                    const appointmentsSnapshot = await doc.ref.collection('appointments').get();
                    patientData.appointments = appointmentsSnapshot.docs.map(snap => ({
                        id: snap.id,
                        ...snap.data()
                    }));

                    // Fetch symptoms
                    const symptomsSnapshot = await doc.ref.collection('symptoms').get();
                    patientData.symptoms = symptomsSnapshot.docs.map(snap => ({
                        id: snap.id,
                        ...snap.data()
                    }));
                } catch (subError) {
                    console.error(`Error fetching subcollections for patient ${doc.id}:`, subError);
                    // Initialize as empty arrays on error
                    patientData.appointments = [];
                    patientData.symptoms = [];
                }

                return patientData;
            });

            const patients = await Promise.all(patientsPromises);

            console.log(`Fetched ${patients.length} patients with subcollections`);
            return patients;
        } catch (error) {
            console.error('Error fetching all patients:', error);
            return [];
        }
    },

    /**
     * Add a new appointment for a patient
     * @param {string} patientId - Patient document ID
     * @param {Object} appointmentData - Appointment data (date, type, notes, recommendedBy)
     * @returns {Promise<boolean>} Success status
     */
    addAppointment: async (patientId, appointmentData) => {
        try {
            if (!db) {
                console.error('Firestore not initialized');
                return false;
            }

            const appointmentsRef = db.collection('users').doc(patientId).collection('appointments');
            await appointmentsRef.add({
                ...appointmentData,
                date: firebase.firestore.Timestamp.fromDate(new Date(appointmentData.date))
            });

            console.log('Appointment added successfully');
            return true;
        } catch (error) {
            console.error('Error adding appointment:', error);
            return false;
        }
    },

    /**
     * Add a new symptom for a patient
     * @param {string} patientId - Patient document ID
     * @param {Object} symptomData - Symptom data (date, symptom, severity, notes)
     * @returns {Promise<boolean>} Success status
     */
    addSymptom: async (patientId, symptomData) => {
        try {
            if (!db) {
                console.error('Firestore not initialized');
                return false;
            }

            const symptomsRef = db.collection('users').doc(patientId).collection('symptoms');
            await symptomsRef.add({
                ...symptomData,
                date: firebase.firestore.Timestamp.fromDate(new Date(symptomData.date))
            });

            console.log('Symptom added successfully');
            return true;
        } catch (error) {
            console.error('Error adding symptom:', error);
            return false;
        }
    },

    /**
     * Get doctor by license number
     * @param {string} license - Doctor's license number
     * @returns {Promise<Object>} Doctor data
     */
    getDoctorByLicense: async (license) => {
        try {
            if (!db) {
                console.error('Firestore not initialized');
                return null;
            }

            // Query doctors collection for doctor with matching license
            const doctorsRef = db.collection('doctors');
            // Updated to match Firestore field name: 'licence_number'
            const snapshot = await doctorsRef.where('licence_number', '==', license).get();

            if (snapshot.empty) {
                console.log(`No doctor found with license: ${license}`);
                return null;
            }

            // Get first matching doctor
            const doc = snapshot.docs[0];
            const data = doc.data();

            // Map Firestore fields to app standard
            return {
                id: doc.id,
                name: data.name,
                license: data.licence_number, // Map back to 'license' for app consistency
                photoURL: data.photoURL || data.image || null,
                ...data
            };
        } catch (error) {
            console.error('Error fetching doctor:', error);
            return null;
        }
    },

    /**
     * Register a new doctor
     * @param {Object} doctorData - Doctor data (name, license, phone)
     * @returns {Promise<Object>} Result object { success: boolean, message: string }
     */
    registerDoctor: async (doctorData) => {
        try {
            if (!db) {
                console.error('Firestore not initialized');
                return { success: false, message: 'Database connection failed' };
            }

            const doctorsRef = db.collection('doctors');

            // Check if license already exists
            const snapshot = await doctorsRef.where('licence_number', '==', doctorData.license).get();
            if (!snapshot.empty) {
                return { success: false, message: 'License number already registered' };
            }

            // Add new doctor
            await doctorsRef.add({
                name: doctorData.name,
                licence_number: doctorData.license,
                phone_number: doctorData.phone,
                photoURL: `https://ui-avatars.com/api/?name=${encodeURIComponent(doctorData.name)}&background=random`,
                createdAt: firebase.firestore.FieldValue.serverTimestamp()
            });

            console.log('Doctor registered successfully');
            return { success: true, message: 'Registration successful' };
        } catch (error) {
            console.error('Error registering doctor:', error);
            return { success: false, message: error.message };
        }
    }

};

// Make it available globally
window.FirebaseService = FirebaseService;
window.initializeFirebase = initializeFirebase;
