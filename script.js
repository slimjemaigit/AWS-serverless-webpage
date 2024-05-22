document.getElementById('getDataBtn').addEventListener('click', async function() {
    try {
        const response = await fetch('https://0c7che91la.execute-api.eu-west-3.amazonaws.com/dev'); // Replace with your actual API Gateway endpoint URL
        const responseData = await response.json();
        
        // Parse the body of the response data
        const data = JSON.parse(responseData.body);

        // Get the response element
        const responseElement = document.getElementById('response');

        // Clear any existing content
        responseElement.innerHTML = '';

        // Loop through the data and create a new line for each item, excluding the ID field
        data.forEach(item => {
            for (const [key, value] of Object.entries(item)) {
                if (key !== 'id') { // Exclude the ID field
                    const line = document.createElement('p');
                    line.textContent = `${key}: ${value}`;
                    responseElement.appendChild(line);
                }
            }
            const lineBreak = document.createElement('br');
            responseElement.appendChild(lineBreak);
        });
    } catch (error) {
        console.error('Error:', error);
    }
});
