# Dockerised API versioning example to test CI/CD with Terraform + Azure Kubernetes service
# Each version of the route will be pushed to check 2 things -
#       1. If successfull CI with Github Actions happen
#       2. If successfull CD push to AKS happens from Github + Terraform

from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def root():
    return jsonify(message="Welcome to Python-Flask-API versioning app!")

@app.route('/version1', methods=['GET'])
def version1():
    return jsonify(message="Python-Flask-API version = 1.0")

# New route handler for the root route
@app.route('/<path:path>', methods=['GET'])
def catch_all(path):
    return jsonify(message="Requested URL was not found"), 404

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5050)