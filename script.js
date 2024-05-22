document.getElementById('getDataBtn').addEventListener('click', async function() {
    try {
        const response = await fetch('https://0c7che91la.execute-api.eu-west-3.amazonaws.com/dev'); // Replace with your actual API Gateway endpoint URL
        const data = await response.json();
        document.getElementById('response').innerText = JSON.stringify(data);
    } catch (error) {
        console.error('Error:', error);
    }
});