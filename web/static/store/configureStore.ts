import configureStoreProd from './configureStore.prod';
import configureStoreDev from './configureStore.dev';

let store: any;

if (process.env.NODE_ENV === 'production') {
  store = configureStoreProd;
} else {
  store = configureStoreDev;
}

export default store;
