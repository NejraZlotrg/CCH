using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class KlijentInsert
    {

        public string? Ime { get; set; }

        public string? Prezime { get; set; }

        public bool? Vidljivo { get; set; }

        public string? Email { get; set; }

        public string? Username { get; set; }

        [Compare("PasswordAgain", ErrorMessage = "Pass don't match")]

        public string? Password { get; set; }

        [Compare("Password", ErrorMessage = "Pass don't match")]
        public string? PasswordAgain { get; set; }
       
        public string? Spol { get; set; }

        public string? BrojTelefona { get; set; }

        public int? GradId { get; set; }
        public int UlogaId { get; set; }
        
    }
}
