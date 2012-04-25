#ifndef LIB_RULES_SERVERMESSENGER_HH_
# define LIB_RULES_SERVERMESSENGER_HH_

# include <memory>

# include <rules/messenger.hh>
# include <net/server-socket.hh>
# include <utils/buffer.hh>

namespace rules {

class Actions;

class ServerMessenger : public Messenger
{
public:
    ServerMessenger(net::ServerSocket_sptr sckt);

    virtual void send(const utils::Buffer&);

    virtual utils::Buffer* recv();
    void recv_actions(Actions* actions);

    void push(const utils::Buffer&);
    void push_actions(Actions& actions);
    void push_id(uint32_t id);

    void ack();

private:
    net::ServerSocket_sptr sckt_;
};

typedef std::shared_ptr<ServerMessenger> ServerMessenger_sptr;

} // namespace rules

#endif // !LIB_RULES_SERVERMESSENGER_HH_
