import rootProd from './Root.prod';
import rootDev from './Root.dev';

let root: any;

if (process.env.NODE_ENV === 'production') {
  root = rootProd;
} else {
  root = rootDev;
}

export default root;
