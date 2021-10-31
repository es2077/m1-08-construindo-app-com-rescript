type requestResult =
  | Data(array<TaskTypes.t>)
  | Loading
  | Error

type hookResult = {
  isCreating: bool,
  result: requestResult,
  taskName: string,
  toggleTaskStatus: TaskTypes.t => unit,
  handleChange: ReactEvent.Form.t => unit,
  handleCreateTask: ReactEvent.Mouse.t => unit,
}

let {queryOptions, useQuery, mutationOptions, useMutation} = module(ReactQuery)
let apiUrl = "http://localhost:3001"
let apiCodec = Jzon.array(TaskTypes.codec)

let handleFetch = _ => {
  open Promise

  Fetch.fetch(`${apiUrl}/tasks`, {"method": "GET"})
  ->then(response => Fetch.json(response))
  ->thenResolve(json => json->Jzon.decodeWith(apiCodec))
}

let handleUpdateTask = task => {
  open Promise

  let json = task->Jzon.encodeStringWith(TaskTypes.codec)

  Fetch.fetch(
    `${apiUrl}/tasks/${task.id->Js.Int.toString}`,
    {
      "method": "PUT",
      "body": json,
      "headers": {
        "Content-Type": "application/json",
      },
    },
  )->thenResolve(response => Js.log(response))
}

let handleCreateTask = (taskName: string) => {
  let newTask = {
    "name": taskName,
    "completed": false,
    "createdAt": Js.Date.make(),
  }

  Fetch.fetch(
    `${apiUrl}/tasks`,
    {
      "method": "POST",
      "body": Js.Json.stringifyAny(newTask),
      "headers": {
        "Content-Type": "application/json",
      },
    },
  )
}

let useTasks = () => {
  let (taskName, setTaskName) = React.useState(_ => "")

  let result = useQuery(
    queryOptions(
      ~queryKey="tasks",
      ~queryFn=handleFetch,
      ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(#bool(false)),
      (),
    ),
  )

  let refetchTasks = () =>
    result.refetch({
      throwOnError: false,
      cancelRefetch: false,
    })

  let handleSuccess = (_, _, _) => {
    setTaskName(_ => "")
    refetchTasks()
  }

  let {mutate: updateTaskMutation} = useMutation(
    mutationOptions(
      ~onSuccess=(_, _, _) => refetchTasks(),
      ~mutationFn=handleUpdateTask,
      ~mutationKey="update-task",
      (),
    ),
  )

  let {mutate: createTaskMutation, isLoading} = useMutation(
    mutationOptions(
      ~onSuccess=handleSuccess,
      ~mutationFn=handleCreateTask,
      ~mutationKey="new-task",
      (),
    ),
  )

  let toggleTaskStatus = task => {
    open TaskTypes

    let updatedTask = {
      ...task,
      completed: !task.completed,
    }

    updateTaskMutation(. updatedTask, None)
  }

  let handleCreateTask = _ => {
    createTaskMutation(. taskName, None)
  }

  let handleChange = event => {
    let target = ReactEvent.Form.target(event)

    setTaskName(_ => target["value"])
  }

  {
    isCreating: isLoading,
    taskName: taskName,
    toggleTaskStatus: toggleTaskStatus,
    handleCreateTask: handleCreateTask,
    handleChange: handleChange,
    result: switch result {
    | {isLoading: true} => Loading
    | {isError: true}
    | {data: Some(Error(_))} =>
      Error
    | {data: Some(Ok(tasks)), isLoading: false, isError: false} => Data(tasks)
    | _ => Error
    },
  }
}
