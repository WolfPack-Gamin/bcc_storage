<template>
  <div :class="{preview: !alignLeft, previewleft: alignLeft}" v-show="activeItem.label">
    <div>{{activeItem.label}}</div>
    <div>{{activeItem.count}}/{{activeItem.limit}}</div>
  </div>
</template>

<script>
export default {
  name: 'Preview',
  props: {
    activeItem: { type: Object, requred: false, default: {} },
    alignLeft: { type: Boolean, requred: false, default: false },
  },
  data () {
    return {
    }
  },
  mounted () {
  },
  methods: {
  }
}
</script>

<style scoped>
    .preview {
        position: absolute;
        right: -210px;
        top: 85px;
        width: 200px;
        /* height: 60px; */
    }

    .previewleft {
        position: absolute;
        left: -210px;
        top: 85px;
        width: 200px;
        /* height: 60px; */
    }

     .preview:before, .previewleft:before {
        content: "";
        position: absolute;
        right: 10px;
        top: 0px;
        z-index: -1;
        width: 200px;
        height: 100%;
        background-image: url(../assets/bg.png);
        background-repeat: no-repeat;
        background-position: center;
        background-size: 100% 100%;
    }
</style>
