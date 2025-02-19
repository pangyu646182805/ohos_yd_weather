// 防抖 在一段时间内函数被多次触发，防抖让函数在一段时间后最终只执行一次
export function debounce(func: () => void, delay?: number) {
  let timer: number | undefined;
  clearTimeout(timer);
  timer = setTimeout(() => {
    func();
  }, delay ? delay : 1000);
}

// 节流 在规定的时间内，只执行一次
export function throttle(func: () => void, delay?: number) {
  let inThrottle = false;
  let timer: number | undefined;
  if (!inThrottle) {
    func();
    inThrottle = true;
    timer = setTimeout(() => {
      clearTimeout(timer)
      inThrottle = false
    }, delay ? delay : 1000);
  }
}