<template>
    <div class="login">
        <img alt="Vue logo" src="../assets/lock.png">
        <input id="email" type="text" placeholder="Email" />
        <input id="password" type="password" placeholder="Password" />
        <button @click="login">Login</button>
    </div>
</template>

<script lang="ts">
import { Options, Vue } from 'vue-class-component';
import { SHA256 } from 'crypto-js';

@Options({
    props: {
    },
})
export default class LoginBox extends Vue {
    // On mount check if the user is already logged in
    async mounted() {
        // Get the code from the query string
        const urlParams = new URLSearchParams(window.location.search);
        const code = urlParams.get('code');
        const state = urlParams.get('state');

        // If the code is present, exchange it for an access token
        if (code) {
            // Exchange the code for an access token
            let tokens = await this.exchangeCode(code);
            if (tokens) {
                // Store the tokens in local storage
                localStorage.setItem('accessToken', tokens.accessToken);
                localStorage.setItem('idToken', tokens.idToken);
                localStorage.setItem('refreshToken', tokens.refreshToken);

                // Redirect to previous page or home
                this.$router.push(state || '/home');
            }
            else {
                // Show an error message
                alert('Invalid code');
            }
        }
    }

    // Exchange the code for an access token
    async exchangeCode(code: string) {
        // POST the code to https://iam.shapley.io/v1/oauth2/token
        const url = 'https://iam.shapley.io/v1/oauth2/token';
        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    client_id: 'iam-ui',
                    code: code,
                    code_verifier: localStorage.getItem('codeVerifier'),
                    grant_type: 'authorization_code',
                    redirect_uri: 'http://localhost:8080/login',
                }),
            });

            // Check response for errors
            if (response.ok) {
                // Get the access token from the response body
                const body = await response.json();
                
                return {
                    accessToken: body.access_token,
                    idToken: body.id_token,
                    refreshToken: body.refresh_token,
                };
            } else {
                return null;
            }
        } catch (error) {
            return null;
        }
    }

    // Submit the login form
    async login() {
        // Get the email and password
        const email = (document.getElementById('email') as HTMLInputElement).value;
        const password = (document.getElementById('password') as HTMLInputElement).value;

        let url = 'https://iam.shapley.io/v1/login';
        try {
            // POST the email and password to https://iam.shapley.io/v1/login
            const response = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    email: email,
                    password: password,
                }),
            });

            // Check response for errors
            if (response.ok) {
                // Get scopes from response body
                const body = await response.json();
                const scopes = body.scopes;

                // Get state from query string
                const urlParams = new URLSearchParams(window.location.search);
                let state = urlParams.get('state');

                // Generate a cryptographically secure nonce and state
                const nonce = window.crypto.getRandomValues(new Uint32Array(4)).join('');

                // Build the external URL
                const url = new URL('https://iam.shapley.io/v1/oauth2/authorize');
                url.searchParams.append('client_id', 'iam-ui');
                url.searchParams.append('response_type', 'code');
                url.searchParams.append('redirect_uri', 'http://localhost:8080/login');
                url.searchParams.append('scope', scopes.join(' '));
                url.searchParams.append('state', state || '/home');
                url.searchParams.append('nonce', nonce);

                // Add pkce parameters
                const codeVerifier = window.crypto.getRandomValues(new Uint32Array(4)).join('');
                localStorage.setItem('codeVerifier', codeVerifier);

                const codeChallenge = await SHA256(codeVerifier);

                url.searchParams.append('code_challenge', codeChallenge);
                url.searchParams.append('code_challenge_method', 'S256');

                // Redirect to the external URL
                window.location.href = url.toString();
            } else {
                // Show an error message
                alert('Invalid email or password');
            }
        } catch (error) {
            alert('Invalid email or password');
        }
    }
}
</script>

<style scoped lang="scss">
// style the login container
.login {
    margin: 100px auto;
    padding: 20px;
    width: 300px;
    border: 1px solid #ccc;
    border-radius: 5px;
}

// style the login image
img {
    margin: 10px;
    width: 100px;
    height: 100px;
}

// style the login form
input {
    margin: 10px;
    padding: 10px;
    width: 200px;
    border: 1px solid #ccc;
    border-radius: 5px;
}

// style the login button
button {
    margin: 10px;
    padding: 10px;
    width: 200px;
    border: 1px solid #ccc;
    border-radius: 5px;
    background-color: #42b983;
    color: white;
    font-weight: bold;
}
</style>