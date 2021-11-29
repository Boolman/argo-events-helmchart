triggers:
  - template:
      name: {{ .Release.Name }}-trigger
      k8s:
        group: argoproj.io
        version: v1alpha1
        resource: workflows
        operation: create
        source:
          resource:
            apiVersion: argoproj.io/v1alpha1
            kind: Workflow
            metadata:
              generateName: ansible-{{ .Release.Name }}-
            spec:
              entrypoint: molecule-runner
              synchronization:
                mutex:
                  name: molecule
              arguments:
                parameters:
                  - name: repo
                    value: "replace me"
                  - name: branch
                    value: master
                  - name: image
                    value: "harbor.openinfra.lan/library/ansible:4.8"
                  - name: project_id
                    value: projectid
                  - name: merge_request_iid
                    value: merge_request_iid
                  - name: commit
                    value: commit
              workflowTemplateRef:
                name: ansible-basic
        parameters:
          - src:
              dependencyName: {{ .Release.Name }}-dep
              dataKey: body.object_attributes.source.git_ssh_url
            dest: spec.arguments.parameters.0.value
          - src:
              dependencyName: {{ .Release.Name }}-dep
              dataKey: body.object_attributes.source_branch
            dest: spec.arguments.parameters.1.value
          - src:
              dependencyName: {{ .Release.Name }}-dep
              dataKey: body.object_attributes.source_project_id
            dest: spec.arguments.parameters.3.value
          - src:
              dependencyName: {{ .Release.Name }}-dep
              dataKey: body.object_attributes.iid
            dest: spec.arguments.parameters.4.value
          - src:
              dependencyName: {{ .Release.Name }}-dep
              dataKey: body.object_attributes.source_project_id
            dest: spec.synchronization.mutex.name
          - src:
              dependencyName: {{ .Release.Name }}-dep
              dataKey: body.object_attributes.last_commit.id
            dest: spec.arguments.parameters.5.value
