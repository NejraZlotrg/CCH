using AutoMapper;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ZaposlenikService : BaseCRUDService<Model.Zaposlenik, Database.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>, IZaposlenikService
    {
        public ZaposlenikService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }

        public override async Task BeforeInsert(Database.Zaposlenik tdb, ZaposlenikInsert insert)
        {
            tdb.LozinkaSalt = GenerateSalt();
            tdb.LozinkaHash = GenerateHash(tdb.LozinkaSalt, insert.Password);
        }

        public static string GenerateSalt()
        {
            RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
            byte[] byteArray = new byte[16];
            provider.GetBytes(byteArray);
            return Convert.ToBase64String(byteArray);
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];
            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);
            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);

            return Convert.ToBase64String(inArray);
        }

        public override IQueryable<Database.Zaposlenik> AddInclude(IQueryable<Database.Zaposlenik> query, ZaposlenikSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            query = query.Include(zaposlenik => zaposlenik.Uloges);

            return base.AddInclude(query, search);
        }


    }
}
