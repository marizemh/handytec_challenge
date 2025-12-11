import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 }, // Ramp up to 20 users
    { duration: '1m', target: 20 },  // Stay at 20 users
    { duration: '10s', target: 0 },  // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must be faster than 500ms
  },
};

export default function () {
  let res = http.get('http://app.handytec.com/'); // Replace with actual URL after deploy
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
  sleep(1);
}
