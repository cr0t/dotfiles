# Git alias for auto-generating changelog entries:
#
# - it looks at all commits since the latest tag
# - it shows the full message with a date identifier
# - it ignores anything that starts with "Bump" (from Dependabot)
#
# Source: [@sorentwo](https://twitter.com/sorentwo/status/1777037533366387067)
function changelog --description="Auto-generate git changelog entries"
    git log --pretty=format:"- %ad %B" --grep="^Bump" --invert-grep --date=short $(git describe --tags --abbrev=0)..HEAD
end
