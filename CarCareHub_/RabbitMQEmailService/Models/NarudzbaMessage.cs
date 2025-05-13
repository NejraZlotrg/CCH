using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EmailService.Models
{
    public class NarudzbaMessage
    {
        public string Email { get; set; }
        public string ImePrezime { get; set; }
        public string BrojNarudzbe { get; set; }
        public DateTime DatumNarudzbe { get; set; }
    }
}

