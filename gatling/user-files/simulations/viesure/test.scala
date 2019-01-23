package viesure

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class TestSimulation extends Simulation {

  // Configuration
  val iterations = Integer.getInteger("iterations", 100).toInt
  val repeats = Integer.getInteger("repeats", 5).toInt
  val paceDuration = Integer.getInteger("pace", 5) seconds
  val host = System.getProperty("host", "http://host.docker.internal:3000")

  // Setup
  val eventPayload = "{ \"limit\": " + iterations + " }"
  val httpProtocol = http
    .baseUrl(host)

  val scnJava = getScenario("java")
  val scnNode = getScenario("nodejs")
  val scnPython = getScenario("python")

  setUp(
    scnJava.inject(atOnceUsers(1)),
    scnNode.inject(atOnceUsers(1)),
    scnPython.inject(atOnceUsers(1))
  ).protocols(httpProtocol)

  def getScenario(url: String) = {
    scenario(url).repeat(repeats) {
      pace(paceDuration)
      exec(http("request_" + url)
        .post("/" + url)
        .body(StringBody(eventPayload))
      )
    }
  }
}
