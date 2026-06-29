# Set up your development environment

First, set up your development environment.

You should now have access to a spreadsheet with credentials and information.
The organizers should have assigned you to a team and shared your team number.

Follow the steps below to get ready for the next stage.

## Get the GitHub organization name

In the spreadsheet, you should find your GitHub organization.
If everything went smoothly, the organizers should have invited your GitHub account to the org.
If in doubt, ask the organizers.

This org is your `work` org. It won't be shared with others so all the content already inside is for you.

## Get the URL of the ephemeral dev environment

In the spreadsheet, you will find the URL of your dev environment.
This is a web-based IDE built on VS Code, so if you are familiar with it, you will feel at home.
The organizers will share the password needed to log in once everyone is ready to start.
In the meantime, you can look around and discover the content already available.

## What you should know

⚠️⚠️⚠️ **IMPORTANT** ⚠️⚠️⚠️ Only `/home/coder/work` is persisted. Store your work there.

- The instance is a Debian-based container, and the default shell is zsh
- Normally, all tools needed are already installed
- If something is missing, you can install it with a command like `sudo apt update && sudo apt install cowsay`
- This environment uses mise (<https://mise.jdx.dev/>) for developer experience, so if you know it, feel free to use it
- Do not change tool versions, for reproducibility

## Set up your environment (finally)

Run the following commands:

```bash
mise install # just to be sure
mise run ssh:setup # no passkey needed
mise run gnupg:setup # no passkey needed
```

⚠️⚠️⚠️ **IMPORTANT** ⚠️⚠️⚠️ The SSH command will ask you at the end to add the generated SSH key to your account.
Do not worry: we will not keep the keys after the workshop, and you can delete them right after the workshop ends.
This is the only way to commit to the organization repository without many compromises.

You now have a ready-to-use development environment with a dedicated SSH key and a GPG key, fully configured.
It is time to start your new dedicated platform!
