﻿using Chillgo.Repository.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Chillgo.Repository.Interfaces
{
    public interface IMessageRepository : IGenericRepository<Message>
    {
        Task<Message> GetByIdAsync(Guid messageId);
    }
}
