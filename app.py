# Dockerised API versioning example to test CI/CD with Terraform + Azure Kubernetes service
# Each version of the route will be pushed to check 2 things -
#       1. If successfull CI with Github Actions happen
#       2. If successfull CD push to AKS happens from Github + Terraform

from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/version1', methods=['GET'])
def version1():
    return jsonify(message="Python-Flask-API version = 1.0")

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5050)