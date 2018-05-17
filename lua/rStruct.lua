-- @Author: weiyanguang
-- @Date: 2018-05-15 11:39:18
-- @Last Modified by: weiyanguang
-- @Last Modified time: 2018-05-15 17:37:37
-- @Doc: base data struct

-- queue
-- empty,size,pop,push,front,back
function queue()
    local q = {first = 0, last = -1}

    function q:empty()
        return self.first > self.last
    end

    function q:push(val)
        local last = self.last + 1
        self.last  = last
        self[last] = val
    end

    function q:pop()
        local first = self.first
        if self:empty() then
            error("queue is empty")
            return nil
        end

        local val   = self[first]
        self[first] = nil
        self.first  = first + 1
        return val
    end

    function q:size()
        return self.last - self.first + 1
    end

    function q:front()
        return self[self.first]
    end

    function q:back()
        return self[self.last]
    end

    return q
end

-- stack
-- push,pop,empty,size,top
function stack()
    local s = {len = 0}

    function s:empty()
        return self.len <= 0
    end

    function s:push(val)
        self.len = self.len + 1
        self[self.len] = val
    end

    function s:pop()
        if self:empty() then
            error("stack is empty")
            return nil
        end

        local val = self[self.len]
        self[self.len] = nil
        self.len = self.len - 1
        return val
    end

    function s:size()
        return self.len
    end

    function s:top()
        return self[self.len]
    end

    return s
end

------------------------------------------------------------------------------
-- -- test queue
-- function test_queue()
--     print("=== test queue ===")
--     local q = queue()
--     q:push(nil)
--     q:push("a")
--     q:push(3)
--     print(q:empty())
--     print(q:pop())
--     print(q:front())
--     print(q:back())
--     print(q:pop())
--     print(q:empty())
-- end

-- -- test stack
-- function test_stack()
--     print("=== test stack ===")
--     local s = stack()
--     s:push(1)
--     s:push(2)
--     s:push(3)
--     print(s:pop())
--     print(s:top())
--     print(s:empty())
--     print(s:pop())
--     print(s:pop())
--     print(s:empty())
-- end

-- test_queue()
-- test_stack()
