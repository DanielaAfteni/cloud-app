package md.utm.cloudapp.rest

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MainController {

    @GetMapping("/")
    fun main(): String {
        return "Hello World! Try today! + GitHub Actions! + 02.06.2025!!! + new! 19:12"
    }
}
