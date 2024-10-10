using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Facebook;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

[Route("api/[controller]")]
[ApiController]
public class FacebookSDKController : ControllerBase
{
    // Endpoint za pokretanje prijave putem Facebooka
    [HttpGet("facebook-login")]
    public IActionResult FacebookLogin()
    {
        var redirectUrl = Url.Action("FacebookResponse", "Auth");
        var properties = new AuthenticationProperties { RedirectUri = redirectUrl };
        return Challenge(properties, FacebookDefaults.AuthenticationScheme);
    }

    // Endpoint za rukovanje odgovorom Facebooka
    [HttpGet("facebook-response")]
    public async Task<IActionResult> FacebookResponse()
    {
        var authenticateResult = await HttpContext.AuthenticateAsync(CookieAuthenticationDefaults.AuthenticationScheme);

        if (!authenticateResult.Succeeded)
            return BadRequest("Prijava putem Facebooka nije uspjela.");

        // Pristupanje podacima logiranog korisnika
        var claims = authenticateResult.Principal.Identities
            .FirstOrDefault()?.Claims.Select(claim => new
            {
                claim.Type,
                claim.Value
            });

        return Ok(claims);
    }
}
