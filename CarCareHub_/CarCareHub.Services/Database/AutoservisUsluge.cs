using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.Database
{
    public class AutoservisUsluge
    {
    public int AutoservisUslugeId { get; set; }
    public int? UslugeId { get; set; }
    public int? AutoservisId { get; set; }
    public Usluge? Usluge { get; set; }
    public Autoservis? Autoservis { get; set; }


    }
}
