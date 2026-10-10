from app.web import app

def test_health():
    assert app.test_client().get('/health').json == {'status': 'healthy'}

def test_calculator_http():
    response = app.test_client().post('/calculate', json={'a': 6, 'b': 3, 'operation': 'multiply'})
    assert response.status_code == 200
    assert response.json == {'result': 18.0}

def test_bad_input():
    assert app.test_client().post('/calculate', json={'a': 1, 'b': 0, 'operation': 'divide'}).status_code == 400
