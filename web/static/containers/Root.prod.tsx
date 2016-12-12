import * as React from 'react';
import { Component } from 'react';
import { Provider } from 'react-redux';
import routes from '../routes';
import { Router } from 'react-router';

interface IRootProps {
  store: any;
  history: any;
}

export default class Root extends Component<IRootProps, any> {
  render() {
    const { store, history } = this.props;
    return (
      <Provider store={store}>
        <Router history={history} routes={routes} />
      </Provider>
    );
  }
}
