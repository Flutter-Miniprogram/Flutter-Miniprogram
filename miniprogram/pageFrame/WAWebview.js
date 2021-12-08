(function() {
  window.exparser = {
    /**
     * @desc 会有很多的自定义组件初始化完毕。
     * @remark 都是一个一个小的shadow-dom
     */
    components: {},
    register: function(e) {
      // 创建root
      var element = document.createElement(e.is);
      // 转化shadow-DOM
      var shadow = element.attachShadow({mode: 'open'});
      // 编译template - loop
      function loopParser(children, root) {
        children.forEach(function(child) {
          var childDOM = document.createElement(child.name);
          // 添加样式
          Object.keys(child.style).forEach(function(key) {
            childDOM.style[key] = child.style[key];
          });
  
          // 如果有文案
          if (child.data) {
            childDOM.innerText = child.data;
          }
  
          // loop判定
          if (child.children) {
            loopParser(child.children, childDOM);
          }
  
          // 添加元素
          root.appendChild(childDOM);
        });
      }
  
      loopParser(e.template(), shadow);

      /// 这里应该挂载一个生成组件函数。因为组件也需要接收动态参数。
      this.components[e.is] = element;
    },
    createVirtualNode: function(data) {
      // 这里应该通过generateFunc获取
      var virtualNode = {
        tag: 'wx-button',
        children: '这是按钮默认文案'
      }
  
      // loop-virtualDOM
      const getVirtualDOM = (root) => {
        var element = this.components[root.tag];
        return element;
      }
  
      var virtualDOM = getVirtualDOM(virtualNode);
  
      document.body.appendChild(virtualDOM);
    },
    listenCustomEventGenerateFunc: (dynamicData) => {
      document.addEventListener('generateFuncReady', function(e) {
        const targetDetail = e.detail;
        /**
         * @desc 获取动态参数
         */
        console.log('dynamicData', dynamicData);
        console.log('generateFunc', typeof targetDetail.generateFunc === 'function');
      })
    }
  }
  
  /**
   * @desc 向组件库中注册组件
   * @desc 注册的组件会存储在注册表(exparser.components)中
   */
  window.exparser.register({
    is: 'wx-button',
    template: function() {
      return [{
        name: 'div',
        style: {
          padding: '20px',
          background: '#1890ff',
          textAlign: 'center',
          borderRadius: '10px',
        },
        children: [{
          name: 'span',
          style: {
            color: '#ffffff'
          },
          data: '默认文案'
        }]
      }]
    }
  })

  window.foundtion = {
    /**
     * @desc 向文档head中插入child方法
     */
    insertDocumentHeadChild(src, type) {
      /**
       * native log
       */
      native.invoke(`insertDocumentHeadChild load! src: ${src} 、 type:${type}`);

      /**
       * @desc 创建业务script并插入
       * @desc 后面改为批量模式
       */
      const scriptNode = document.createElement('script');
      scriptNode.type = type || 'text/javascript';
      scriptNode.src = src;
      document.head.appendChild(scriptNode);

      this.addGenerateFuncReady();

      this.replaceDocumentReadyScript();
    },
    /**
     * @desc 添加generateFuncReady CE
     */
    addGenerateFuncReady() {
      const scriptNode = document.createElement('script');
      scriptNode.innerHTML = `
        var decodeName = decodeURI('index.wxml');
        var generateFunc = $gwx(decodeName);

        if (generateFunc) {
          var CE = (typeof __global === 'object') ? (window.CustomEvent || __global.CustomEvent) : window.CustomEvent;
          document.dispatchEvent(new CE("generateFuncReady", {
            detail: {
              generateFunc: generateFunc,
            }
          }))
        }
      `;
      /**
       * @question 这里插入的时候获取不到$gwx,这个问题需要排查
       */
      setTimeout(() => {
        document.head.appendChild(scriptNode);
      }, 200)
    },
    replaceDocumentReadyScript() {
      var scripts = document.getElementsByTagName('script');
      var noticeScript = scripts[scripts.length - 1];

      noticeScript.parentNode.removeChild(noticeScript);
    }
  }

  window.native = {
    invoke: function(method) {
      try {
        Native.postMessage(JSON.stringify({
          method: method,
        }))
      } catch (e) {
        console.log('[To Developer]- invoke Error', e);
      }
    }
  }
})()