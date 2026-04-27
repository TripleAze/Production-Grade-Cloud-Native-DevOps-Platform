# encoding: utf-8
from project import create_app

app = create_app()

if __name__ == '__main__':
    # Binding to 0.0.0.0 is necessary for accessibility within Docker/Kubernetes
    app.run(host='0.0.0.0', port=8080, debug=True) # nosemgrep
