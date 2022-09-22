<template>
  <div class="load-modal" v-show="showing">
    <div class="wrap-model">
      <div class="revolver">
        <section class="revolver__part"></section>
        <section class="revolver__part"></section>
        <section class="revolver__part"></section>
        <section class="revolver__part"></section>
        <section class="revolver__part"></section>
        <section class="revolver__part"></section>
      </div>
    </div>

    <div class="loading">{{message}}</div>
  </div>
</template>

<script>
export default {
  name: 'Spinner',
  props: {
    message: { type: String, requred: false, default: "Loading..." },
    showing: { type: Boolean, requred: false, default: false },
  },
  data () {
    return {
    }
  }
}
</script>


<style scoped>
.load-modal {
  background-image: url(../assets/bg.png);
  background-repeat: no-repeat;
  background-position: center;
  background-size: 100% 100%;
  height: 170px;
  width: 200px;
  position: absolute;
  top: 50%;
  left: 50%;
  border-radius: 2px;
  transform: translate(-50%, -50%);
  
}

.wrap-model {
  height: 80px;
  width: 80px;
  position: absolute;
  top: 20%;
  left: 50%;
  transform: translate(-50%, -20%);
  padding: 10px;
}

.loading {
  margin-top: 120px;
  text-align: center;
}

.revolver {
  height: 80px;
  width: 80px;
  border-radius: 50px;
  display: flex;
  justify-content: center;
  background: #ccc;
  transform: rotate(30deg);
  -webkit-animation: rotate 6.5s cubic-bezier(0.74, 0.61, 0, 1.33) infinite;
          animation: rotate 6.5s cubic-bezier(0.74, 0.61, 0, 1.33) infinite;
  text-align: middle;
  position: relative;
}
.revolver__part {
  height: 40px;
  width: 30px;
  border-radius: 5px;
  transform-origin: bottom center;
  position: absolute;
  display: flex;
  justify-content: center;
}
.revolver__part:after, .revolver__part:before {
  content: " ";
  display: block;
  background: #000000;
  height: 26px;
  width: 26px;
  border-radius: 13px;
  margin-top: -18px;
}
.revolver__part:before {
  position: absolute;
  height: 12px;
  width: 12px;
  margin-top: 11px;
  right: -5px;
  background: #000000;
  border: 2px solid #000000;
}

section:nth-of-type(1) {
  transform: rotateZ(calc(60deg * 1));
}

section:nth-of-type(2) {
  transform: rotateZ(calc(60deg * 2));
}

section:nth-of-type(3) {
  transform: rotateZ(calc(60deg * 3));
}

section:nth-of-type(4) {
  transform: rotateZ(calc(60deg * 4));
}

section:nth-of-type(5) {
  transform: rotateZ(calc(60deg * 5));
}

section:nth-of-type(6) {
  transform: rotateZ(calc(60deg * 6));
}

@-webkit-keyframes rotate {
  0% {
    transform: rotate(30deg);
  }
  16% {
    transform: rotate(90deg);
  }
  32% {
    transform: rotate(150deg);
  }
  48% {
    transform: rotate(210deg);
  }
  64% {
    transform: rotate(270deg);
  }
  82% {
    transform: rotate(330deg);
  }
  100% {
    transform: rotate(390deg);
  }
}

@keyframes rotate {
  0% {
    transform: rotate(30deg);
  }
  16% {
    transform: rotate(90deg);
  }
  32% {
    transform: rotate(150deg);
  }
  48% {
    transform: rotate(210deg);
  }
  64% {
    transform: rotate(270deg);
  }
  82% {
    transform: rotate(330deg);
  }
  100% {
    transform: rotate(390deg);
  }
}

</style>
