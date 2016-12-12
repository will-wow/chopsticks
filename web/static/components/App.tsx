import * as React from 'react';
import { Link } from 'react-router';

const App = ({ children }) =>
  <div className="row">
    <h1>Filter table</h1>
    {children}
    <footer>
      <Link to="/">Filterable Table</Link>
      <Link to="/about">About</Link>
    </footer>
  </div>;

export default App;
