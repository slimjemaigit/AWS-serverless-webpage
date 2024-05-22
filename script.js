document.getElementById('getDataBtn').addEventListener('click', async function() {
    try {
        const response = await fetch('https://k7yo4hfnvi.execute-api.eu-west-3.amazonaws.com/dev'); // Replace with your actual API Gateway endpoint URL
        const data = await response.json();
        
        // Parse the JSON data and construct the string to display
        let formattedData = '';
        data.forEach(item => {
            for (const [key, value] of Object.entries(item)) {
                formattedData += `${key}: ${value}\n`;
            }
            formattedData += '\n'; // Add an extra newline for separation between items
        });

        // Display the formatted data in the response element
        document.getElementById('response').innerText = formattedData;
    } catch (error) {
        console.error('Error:', error);
    }
});
