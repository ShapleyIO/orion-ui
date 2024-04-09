<template>
  <div class="login">
    <LoginBox />
  </div>
</template>

<script lang="ts">
import { Options, Vue } from 'vue-class-component';
import LoginBox from '@/components/LoginBox.vue'; // @ is an alias to /src

@Options({
  components: {
    LoginBox,
  },
})
export default class Login extends Vue { }
</script>
