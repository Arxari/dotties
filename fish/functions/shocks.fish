function fish_command_not_found
    set -l api_key "your_api_key"  # Replace with your API key
    set -l shock_id "your_shock_id"  # Replace with your shocker ID
    set -l intensity 50  # Set the intensity (0-100)
    set -l duration 1000  # Set the duration in milliseconds
    set -l shock_type "Shock"  # Can also vibrate or beep

    echo "Command '$argv' not found. Sending shock..."

    set response (curl -s -w "%{http_code}" -o /dev/null -X POST \
        "https://api.shocklink.net/2/shockers/control" \
        -H "accept: application/json" \
        -H "OpenShockToken: $api_key" \
        -H "Content-Type: application/json" \
        -d '{
            "shocks": [{
                "id": "'"$shock_id"'",
                "type": "'"$shock_type"'",
                "intensity": '"$intensity"',
                "duration": '"$duration"',
                "exclusive": true
            }],
            "customName": "Linux terminal shock aided learning tool"
        }')

    if test "$response" = "200"
        echo "$shock_type sent successfully."
    else
        echo "Failed to send $shock_type. Response code: $response"
    end
end

functions -c fish_command_not_found __fish_command_not_found
