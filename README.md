# SAP - Silicon Authentication Platfrom

**Abstract:**
The increasing complexity of system-on-chip (SoC) designs, prompted by the integration of additional functionalities, has led to a reliance on global sources in the SoC supply chain. This reliance introduces security concerns, including intellectual property (IP) theft, unauthorized usage, counterfeiting, and overproduction of integrated circuits (ICs). While various design-for-trust measures have been explored in academic research, such as watermarking, IC metering, IC camouflaging, and hardware obfuscation, there is currently no holistic approach within the SoC framework to support these measures. Secure provisioning of security assets within the chip is also critical for these measures, requiring the establishment of secure communication channels and the authentication of the chip by authorized entities. Existing root-of-trust mechanisms primarily target software-level threats during in-field operations but fall short of adequately addressing supply chain threats and ensuring secure asset provisioning. This paper introduces the Silicon Authentication Platform (SAP) security IP, specifically designed to address security vulnerabilities within the SoC supply chain. SAP is tailored to authenticate SoC dies within untrusted environments, ensuring secure provisioning of security assets and chip authentication during in-field operations. This hardware-based, plug-and-play IP facilitates lightweight integration into SoC designs, establishing a secure perimeter around its assets to protect them from potential leakage. In addition, a comprehensive security analysis showcasing SAP's resilience against contemporary attack scenarios, with minimal impact on performance and area overhead, is also provided in this paper.

**Note:** Please cite our paper if SAP IP is useful for your research.

@inproceedings{sami2024sap,
  title={SAP: Silicon Authentication Platform for System-on-Chip Supply Chain Vulnerabilities},
  author={Sami, Md Sami Ul Islam and Zhou, Jingbo and Saha, Sujan Kumar and Rahman, Fahim and Farahmandi, Farimah and Tehranipoor, Mark},
  booktitle={2024 IEEE International Symposium on Performance Analysis of Systems and Software (ISPASS)},
  pages={109--119},
  year={2024},
  organization={IEEE}
}
