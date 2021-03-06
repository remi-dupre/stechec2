// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2012 Association Prologin <association@prologin.org>
#include "message.hh"

#include <cstring>
#include <ostream>
#include <sstream>

namespace net
{

Message::Message(uint32_t type, uint32_t client_id)
    : type(type)
    , client_id(client_id)
{
}

std::string Message::str() const
{
    std::stringstream ss;

    ss << "type      : " << type << "\n"
       << "client_id : " << client_id;

    return ss.str();
}

} // namespace net

std::ostream& operator<<(std::ostream& os, const net::Message& msg)
{
    os << msg.str() << std::endl;

    return os;
}
