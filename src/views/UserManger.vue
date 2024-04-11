<template>
    <div class="user-management">
      <UserManagment />
    </div>
  </template>
  
  <script lang="ts">
  import { Options, Vue } from 'vue-class-component';
  import UserManagment from '@/components/UserManagment.vue'; // @ is an alias to /src
  
  @Options({
    components: {
      UserManagment,
    },
  })
  export default class Login extends Vue { }
  </script>
  