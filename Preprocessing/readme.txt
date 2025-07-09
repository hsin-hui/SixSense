For executing multiple or single subjects 
Steps:
1) Open terminal at /home/commmunicationlab/fmri
2)For using fmriprep for multiple/single subjects use the following command:
sudo python3 script.py

Note:-  Read configuration.txt once.
        Enter the password whenever asked by the terminal. (password: communication)

3)If any error occurs regarding docker use the following command:
sudo systemctl start docker

4)For checking status of docker use the following command:
systemctl status docker

5)Now fmriprep will do its task of preprocessing and output will be stored in derivatives folder in bids root directory

For extracting the motion corrected files using fsl
Steps:
1)Open terminal
2)For using FSL for extracting the files use the following command:
sudo bash ./code9.sh /home/om/Documents/bids 01 4 10 docker 6

Note: According to the path specified in user input the command will change.

3)FSL will perform the extraction and output files will be stored in the derivatives folder
