using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class GradSearchObject: BaseSearchObject
    {
        public string? NazivGrada { get; set; }
        public bool IsDrzavaIncluded { get; set; }

    }
}
