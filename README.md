# Update for this Fork of the project
As I gave ChaosSlingr a try it wasn't straightforward from the beginning what AWS resources are needed to run the tests.

So to make things easier, the lambdas creation, corresponding role, policy, CloudWatcg log group and event rule are all created automatically with Terraform. These resources are located in the new folder `test/lambdas_terraform`.

## How to Run
- `cd` in the project folder and create the python virtual environment:
  - `pip3 install --upgrade pip; pip install --upgrade pip`
  - `python3 -m venv venv3`
  - `source venv3/bin/activate`
  - and install python requirements `pip3 install -r requirements.txt`
- `cd test/lambdas_terraform` to spin up the AWS Lambdas and linked resources with Terraform. Check this [README](test/lambdas_terraform/README.md) for details on this step.
  - The three Lambdas will be created, along with a [role and policy](https://github.com/alexandrumd/ChaoSlingr/blob/a7d6182d566e5e14b98684c77c8a5540d0799738/test/lambdas_terraform/lambda_slingr.tf#L6-L81), to be used in common. Check the .tf files for details.
  - A CloudWatch Log Group (`/aws/lambda/PortChange_Slingr`) is used in common by the Lambdas.
  - A CloudWatch [event rule](https://github.com/alexandrumd/ChaoSlingr/blob/a7d6182d566e5e14b98684c77c8a5540d0799738/test/lambdas_terraform/lambda_trackr.tf#L15) is used to trigger the `PortChange_Slack_Trackr` Lambda function in case of changes to Security Groups.
- Go to `test/PortChange_Generatr` folder and `./run-test.sh`
  - This will create 3 Security Groups with different opt-in tags for testing: one with the `OptMeInTest` tag set to `true`, another with the tag set to `false` and last one not having this tag.
  - It will then invoke the `PortChange_Generatr` Lambda, supplying the `OptMeInTest` tag as parameter.
  - The function will iterate security groups and select those having this tag and its value set to `true`.
  - It will then [invoke](https://github.com/alexandrumd/ChaoSlingr/blob/a7d6182d566e5e14b98684c77c8a5540d0799738/src/lambda/PortChange_Generatr.py#L92) the `PortChange_Slingr` Lambda, that will "sling" the group - open up random ports.
  - These events will also trigger the `PortChange_Slack_Trackr_rule` CloudWatch event rule, that will trigger in its turn the `PortChange_Slack_Trackr` Lambda function, that will finally [push the notification to the configured Slack Incoming WebHooks](https://github.com/alexandrumd/ChaoSlingr/blob/a7d6182d566e5e14b98684c77c8a5540d0799738/test/lambdas_terraform/lambda_trackr.tf#L59-L64).
  - Finally, the Security Groups will be destroyed.

### Cleanup
To remove the Lambdas and corresponding resources, `cd test/lambdas_terraform` and run `terraform destroy`.

# Changes compared to original
- Updated python requirements - awscli==1.16.308 and boto3==1.10.44
- Updated terraform version to 0.11.3
- Add `test/lambdas_terraform` to automatically build the needed resources with Terraform


---

Original README follows.

---

![FileImage](./docs/Files.png)

Thanks for your interest in Optum’s ChaoSlingr project!  Unfortunately, we have moved on and this project is no longer actively maintained or monitored by our Open Source Program Office.  This copy is provided for reference only.  Please fork the code if you are interested in further development.  The project and all artifacts including code and documentation remain subject to use and reference under the terms and conditions of the open source license indicated.  All copyrights reserved.


![ChaoSlingrLogo](./docs/ChaoSlingrLogo.jpg)

# ChaoSlingr: Introducing Security into Chaos Testing

ChaoSlingr is a Security Chaos Engineering Tool focused primarily on the experimentation on AWS Infrastructure to bring system security weaknesses to the forefront.

Security is chaotic and the industry has traditionally put emphasis on the importance of preventative security control measures and defense-in-depth where-as our mission is to drive new knowledge and perspective into the attack surface by delivering proactively through detective experimentation.

With so much focus on the preventative mechanisms we never attempt beyond one-time or annual pen testing requirements to actually validate whether or not those controls actually are performing as designed.

Our mission is to address security weaknesses proactively, going beyond the reactive processes that currently dominate traditional security models.

![ChaoSlingr Diagram](./docs/ChaoSlingr_designAndArchitecture.jpg?raw=true "ChaoSlingr Diagram")

## Contributing to the Project

The ChaoSlingr team is open to contributions to our project.  For more details, see our [Contribution Guide](CONTRIBUTING.md) and join the discussion on [Slack](https://chaoslingr.slack.com).

## Original Contributors

* Aaron Rinehart (@AARonSTeneo)
* Grayson Brewer (@egb2016)
* Josh Gorton (@Jgorton612928)
* Amy L Schoen (@amyschoen)
* Mehul Shah (@mehul0sejal)
* Shawn Ertel (@SHA34)
* Samuel W Roden (@sbroden)
* Joseph P Niquette (@Joeyn414)
* Stephen M Klugherz (@Smklugherz)
* Alex R Nielsen (@anielse2)
* Arun K Singh (@Oarusoft)
* Rajitha Ramasayam (@rajitha-ramasayam)
* David W Cloninger (@dcloninger)
* Mike Zhou (@MichaelLiZhou)
* Dan Brock (@Bluephish)

### Special Thanks

* John Garner
* Sean O'Neil
* Patrick E Bergstrom (@IAmPatrickB)
* Scott Maciej (@sgm44)
* Magnus J Hedemark (@magnus919)
* Kevin Nelson (@pkn4645)
* Sridhar R
* Michael R Baker
* Randy Olinger
* David S Hanauer
* Ryan Wencl
* Bryce Ashey
* RJ Seibert (@alephnot0)
* Angela Mulcahy
* Joseph C Kollasch
* Andrew R Brennan
* Kyle J Erickson
* Daniel Henry
* Brandon Jeup
* Robert J Dufek
* Heather Mickman
* Barbara J Doenges
* Hugh Smith
* Tomo Lennox
* Norman O'Neal
* Henry B Kono
* Zachary S Brown (@ZacharySBrown)
* Nicholas S Kerling
* Jeff Sivori
* Marcus Maday
* Joel E Carlson (@joelelmercarlson)
* Shelby R Erickson
