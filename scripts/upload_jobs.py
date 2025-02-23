import sys
import subprocess
import traceback

def install(package):
    try:
        # Use subprocess to run pip with elevated privileges
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--user', package])
    except subprocess.CalledProcessError as e:
        print(f"Error installing {package}: {e}")
        print("Detailed error:")
        traceback.print_exc()
        raise

def main():
    try:
        import json
        import firebase_admin
    except ImportError:
        print("Some required packages are missing. Attempting to install...")
        try:
            install('firebase-admin')
        except Exception as e:
            print(f"Critical error during package installation: {e}")
            print("Please try these steps:")
            print("1. Ensure Python is correctly installed")
            print("2. Run 'python -m pip install --upgrade pip'")
            print("3. Run 'python -m pip install firebase-admin'")
            sys.exit(1)

    try:
        from firebase_admin import credentials, firestore
    except ImportError:
        print("Failed to import Firebase Admin SDK. Ensure you have:")
        print("1. Installed firebase-admin package")
        print("2. Have a valid service account key")
        sys.exit(1)

    # Path to your Firebase service account key JSON file
    cred_path = 'firebase_service_account.json'
    
    # Detailed error handling for file access
    import os
    print(f"Current working directory: {os.getcwd()}")
    print(f"Attempting to use service account key: {cred_path}")
    print(f"Absolute path: {os.path.abspath(cred_path)}")
    print(f"File exists: {os.path.exists(cred_path)}")
    
    # If file doesn't exist, try to locate it
    if not os.path.exists(cred_path):
        # Try to find the file in the current directory or parent directories
        current_dir = os.getcwd()
        for _ in range(3):  # Search up to 3 levels up
            possible_paths = [
                os.path.join(current_dir, 'firebase_service_account.json'),
                os.path.join(current_dir, 'scripts', 'firebase_service_account.json')
            ]
            for path in possible_paths:
                if os.path.exists(path):
                    cred_path = path
                    print(f"Found service account key at: {cred_path}")
                    break
            if cred_path != 'firebase_service_account.json':
                break
            current_dir = os.path.dirname(current_dir)
    
    # Raise an error if file still can't be found
    if not os.path.exists(cred_path):
        raise FileNotFoundError(f"Could not find Firebase service account key. Searched at: {cred_path}")

    try:
        # Initialize Firebase Admin SDK
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)

        # Get Firestore client
        db = firestore.client()

        # Path to your jobs JSON file
        jobs_file = 'lib/data/jobs.json'

        # Read jobs from JSON
        with open(jobs_file, 'r') as f:
            jobs_data = json.load(f)

        # Reference to jobs collection
        jobs_collection = db.collection('jobs')

        # Upload each job
        for job_id, job_details in jobs_data['jobs'].items():
            try:
                # Add job to Firestore with custom document ID
                jobs_collection.document(job_id).set(job_details)
                print(f'Successfully uploaded job: {job_details["title"]}')
            except Exception as e:
                print(f'Error uploading job {job_id}: {e}')

        print('Job upload complete!')

    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        traceback.print_exc()

if __name__ == '__main__':
    main()
