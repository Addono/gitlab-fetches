<br />
<h1 align="center">gitlab-fetches</h3>

<p align="center">
  <p align="center">
     Get historical fetch statistics for GitLab projects
  <br/>

  <a href="https://github.com/Addono/gitlab-fetches/graphs/contributors">
  <img src="https://img.shields.io/github/contributors/Addono/gitlab-fetches.svg?style=flat-square">
  </a>
  <a href="https://github.com/Addono/gitlab-fetches/network/members">
  <img src="https://img.shields.io/github/forks/Addono/gitlab-fetches.svg?style=flat-square">
  </a>
  <a href="https://github.com/Addono/gitlab-fetches/stargazers">
  <img src="https://img.shields.io/github/stars/Addono/gitlab-fetches.svg?style=flat-square">
  </a>
  <a href="https://github.com/Addono/gitlab-fetches/blob/master/LICENSE">
  <img src="https://img.shields.io/github/license/Addono/gitlab-fetches.svg?style=flat-square">
  </a> 
  <a href="https://github.com/Addono/gitlab-fetches/actions">
  <img src="https://img.shields.io/github/actions/workflow/status/Addono/gitlab-fetches/ci.yml?style=flat-square&logo=github%20actions">
  </a> 
  <a href="https://github.com/Addono/gitlab-fetches/releases">
  <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/Addono/gitlab-fetches?style=flat-square">
  </a>
  <a href="https://github.com/Addono/gitlab-fetches/releases">
  <img alt="Script file size" src="https://img.shields.io/github/size/Addono/gitlab-fetches/src/gitlab-fetches.sh?style=flat-square&color=green">
  </a>
    
  <br/>
  
  <a href="https://github.com/Addono/gitlab-fetches/pkgs/container/gitlab-fetches">
    <strong>View on GitHub Container Registry</strong>
  </a>
  
  <br/>
  <a href="https://github.com/Addono/gitlab-fetches#examples"><strong>Example usage</strong></a>
  ·
  <a href="https://github.com/Addono/gitlab-fetches/pulls">Submit a PR</a>
  </p>
</p>

`./src/gitlab-fetches.sh` is a script designed to fetch historical data from the GitLab API. It is [sh](https://en.wikipedia.org/wiki/Bourne_shell) and [alpine](https://alpinelinux.org/) compatible. This project is a rewrite of the original [Eficode/wait-for](https://github.com/Eficode/wait-for) repository, repurposed for a new use case.

The easiest way to get started using this tool is to include the `src/gitlab-fetches.sh` file as part of your project. Then call this script as part of any automation script.

## Usage

### Locally

Download the `gitlab-fetches.sh` file from the `src` directory, either the latest from [`main`](https://raw.githubusercontent.com/Addono/gitlab-fetches/main/src/gitlab-fetches.sh) or for a specific version check out the [Releases](https://github.com/Addono/gitlab-fetches/releases)-page.

With the file locally on your file system, you can directly invoke it.

```
./src/gitlab-fetches.sh [ --token <token> ] <gitlab_project_url...>
  --token <token>  GitLab API token with the `read_api` scope. Can also be set with GITLAB_TOKEN env var.
  -h, --help       Display this help message.
  -v, --version    Display the version number.
```

### GitHub Actions

You can use this script in a GitHub Action to gather statistics about a GitLab project:

```yaml
      - name: Fetch GitLab Stats
        run: |
          wget -qO- https://raw.githubusercontent.com/Addono/gitlab-fetches/main/src/gitlab-fetches.sh | \
          sh -s -- --token ${{ secrets.GITLAB_TOKEN }} https://gitlab.com/gitlab-org/gitlab
```

### Docker

We also publish a container to the GitHub Container Registry at [`ghcr.io/addono/gitlab-fetches`](https://github.com/Addono/gitlab-fetches/pkgs/container/gitlab-fetches). We publish under the tag `latest` what's in `main` and tags for each release. You can use the container like this:

```bash
$ docker run --rm -e GITLAB_TOKEN=$YOUR_GITLAB_TOKEN ghcr.io/addono/gitlab-fetches https://gitlab.com/gitlab-org/gitlab
```

## Examples

To get statistics for a single project:

```
$ ./src/gitlab-fetches.sh --token "your-token" https://gitlab.com/gitlab-org/gitlab
{
  "gitlab-org/gitlab": {
    "historical": [
      {
        "date": "2025-08-19",
        "fetches": 20
      }
    ],
    "total": 20
  }
}
```

To get statistics for multiple projects at once:

```
$ ./src/gitlab-fetches.sh --token "your-token" https://gitlab.com/gitlab-org/gitlab https://gitlab.com/gitlab-org/gitlab-runner
{
  "gitlab-org/gitlab": {
    "historical": [
      {
        "date": "2025-08-19",
        "fetches": 20
      }
    ],
    "total": 20
  },
  "gitlab-org/gitlab-runner": {
    "historical": [
      {
        "date": "2025-08-19",
        "fetches": 15
      }
    ],
    "total": 15
  }
}
```

## Testing

Testing is done using Node.js's built-in test runner. We use it to execute the shell script and assert its behavior.

For reproducibility, we run our tests inside Docker, such that we have control over the versions of `bash`, `curl`, and `jq` we're testing against.

```bash
docker build --target test-env --tag gitlab-fetches-test .
docker run --rm -t gitlab-fetches-test
```

## Contributing

When creating PRs, please style your commit messages according to [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/), you can use a tool like [commitizen](https://github.com/commitizen/cz-cli) to guide you. We will automatically infer the changelog from your commits. Alternatively, we can squash all commits when merging and update the commit message.

This project strongly prefers maintaining backwards compatibility, therefore some obvious "fixes" might not be accepted.

Also, please include or update the test cases whenever possible by extending `test/test.js`.

## Note

Make sure `bash`, `curl`, and `jq` are installed in your environment before running the script.

## License

This tool is released under the MIT license. It's derived from:

<details>
<summary><a href="https://github.com/eficode/wait-for">wait-for</a>: MIT license, 2027 Eficode Oy</summary>
The MIT License (MIT)

Copyright (c) 2017 Eficode Oy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

</details>