echo "This is our provisioning script"
apt-get clean
apt-get update
apt-get install vim -y
apt-get install xsel -y
apt-get install tree -y
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'