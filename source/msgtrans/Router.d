module msgtrans.Router;

import msgtrans.Command;

class Router
{
    private
    {
        __gshared Router _grouter = null;
        Command[long] _actions;
    }

    static Router instance()
    {
        if (_grouter is null)
            _grouter = new Router();
        return _grouter;
    }

    public void registerProcessHandler(M)(int messageId)
    {
        auto action = new M();
        _actions[messageId] = action;
    }

    public Command getProcessHandler(long messageId)
    {
        return _actions.get(messageId, null);
    }
}
