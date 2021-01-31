class FSM // finite state machine class for enemy logic
{
	public var activeState:Float->Void; // declare active state variable

	public function new(initialState:Float->Void) // initial state function
	{
		activeState = initialState; // sets active state to initial state
	}

	public function update(elapsed:Float)
	{
		activeState(elapsed);
	}
}
