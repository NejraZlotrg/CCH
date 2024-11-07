using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class AutoservisSearchObject : BaseSearchObject
    {
        public bool? IsAllIncluded { get; set; }
        
        public string? NazivGrada { get; set; }

        //  public string? Naziv { get; set; }
    }
}
