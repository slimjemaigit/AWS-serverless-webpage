document.getElementById('getDataBtn').addEventListener('click', async function() {
    try {
        const response = await fetch('https://your-api-gateway-url.com/example'); // Replace with your actual API Gateway endpoint URL
        const data = await response.json();
        document.getElementById('response').innerText = JSON.stringify(data);
    } catch (error) {
        console.error('Error:', error);
    }
});
