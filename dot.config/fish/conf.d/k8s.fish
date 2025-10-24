if type -q kubectl
    function kpods --argument-names podsname namespace --description="Search for pods"
        kubectl get pods -n $namespace --no-headers | grep $podsname
    end

    function klogs --argument-names podname namespace cmd --description="Tail logs of a pod"
        set podname (kpods $podname $namespace | awk '{print $1}' | awk -F'-' 'NF==4' | head -n 1)
        kubectl logs -f $podname -n $namespace
    end

    function kexec --argument-names podname namespace cmd --description="Execute a one-time command"
        kubectl exec -it $podname -n $namespace -- $argv[3..]
    end

    function krails --argument-names podname namespace --description="Run Rails console"
        set podname (kpods $podname $namespace | awk '{print $1}' | awk -F'-' 'NF==4' | head -n 1)
        kexec $podname $namespace bundle exec rails c
    end
end
