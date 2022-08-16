package main

import (
	"crypto/x509"
	"encoding/pem"
	"errors"
	"io/ioutil"
	"time"

	log "github.com/sirupsen/logrus"
)

func main() {
	log.SetFormatter(&log.JSONFormatter{})

	log.SetLevel(log.WarnLevel)
	standardFields := log.Fields{
		"app":           "service",
		"app_live":      "app_live",
		"country":       "country",
		"env":           "env",
		"slack_channel": "slack_channel",
		"squad":         "dh_squad",
		"tribe":         "dh_tribe",
		"version":       "version",
	}

	log := log.WithFields(standardFields)-

	done := make(chan bool)
	checkCertValidity("./ca.crt", log)
	go func() {
		defer close(done)

		for {
			select {
			case <-done:
				return
			default:
				err := checkCertValidity("./ca.crt", log)
				if err != nil {
					//report
				}
			}

		}
	}()
	<-done

}

func checkCertValidity(path string, log *log.Entry) error {

	crtStr, err := ioutil.ReadFile(path)
	if err != nil {
		return err
	}
	block, rest := pem.Decode([]byte(crtStr))
	if block == nil || len(rest) > 0 {
		return errors.New("CERTIFICATE DECODING ERROR")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return err
	}

	nextMonth := time.Now().AddDate(0, 1, 0)
	certExpiry := cert.NotAfter

	//if diff < 30 days start WARN
	diffDays := certExpiry.Sub(nextMonth).Hours() / 24
	if diffDays <= 0 {
		//panic
		log.Panicf("Certificate is going to get expire in %f\n", diffDays)
	} else if diffDays >= 0 && diffDays <= 30 {
		//WARN
		log.Warnf("Certificate is going to get expire in %f\n", diffDays)
	} else {
		//INFO days
		log.Debugf("Certificate is going to get expire in %f\n", diffDays)

	}
	return nil
}
