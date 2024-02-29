using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IProizvodiService
    {
        public IList<Proizvod> Get();
    }
}
