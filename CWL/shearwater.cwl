cwlVersion: v1.0
$graph:
  - class: Workflow
    id: shearwater_workflow
    requirements: []
    inputs:
      start_day:
        type: string
          
      end_day:
        type: string

    outputs:
      - id: demo_csv
        outputSource:
          - shearwater1/demo_csv
        type: Directory
    
    steps:
      shearwater1:
        run: "#shearwater"
        in: 
          start_day: start_day
          end_day: end_day
        out:
          - demo_csv
  - class: CommandLineTool
    id: shearwater
    requirements:
        InitialWorkDirRequirement:
          listing:
          - entryname: app.sh
            entry: |-
                #!/bin/bash
                echo $1 $2 $3 $4
                python -m app $0 $1 $2 $3 $4
          - entryname: catalog.json
            entry: |-  
                {
                    "id": "catalog",
                    "stac_version": "1.0.0",
                    "links": [
                        {
                            "type": "application/geo+json",
                            "rel": "item",
                            "href": "result-item.json"
                        },
                        {
                            "type": "application/json",
                            "rel": "self",
                            "href": "catalog.json"
                        }
                    ],
                    "type": "Catalog",
                    "description": "Root catalog"
                }
          - entryname: app.py
            entry: |-
                import pystac,json,sys
                from datetime import datetime, timezone
                print("OK", file=sys.stderr)
                print(sys.argv, file=sys.stderr)
                print("OK", file=sys.stderr)
                import shearwater.processes.wps_cyclone_demo as toto
                tata=toto.Cyclone()
                inputs={"start_day": "2022-01-01","end_day": "2022-01-31"}
                outputs={}
                #tata._handler(inputs["start_day"],inputs["end_day"],outputs)
                tata._handler(sys.argv[1],sys.argv[2],outputs)
                datetime_utc = datetime.now(tz=timezone.utc)
                item = pystac.Item(id='result-item',
                    geometry=[-180,-90,180,90],
                    bbox=[-180,-90,180,90],
                    datetime=datetime_utc,
                    properties={})
                item.add_asset(key='demo_csv', asset= pystac.Asset(href='prediction_Sindian.csv', media_type=pystac.MediaType.TEXT))
                open("result-item.json","w").write(json.dumps(item.to_dict(), indent=4))

        EnvVarRequirement:
          envDef:
            PYTHONPATH: /app
        ResourceRequirement:
          coresMax: 1
          ramMax: 512
        DockerRequirement:
          dockerPull: shearwater:latest
    baseCommand: ["/bin/bash", "-c", ". ./app.sh"]
    arguments: []
    inputs:
      start_day:
        type: string
        inputBinding:
          position: 1
          
      end_day:
        type: string
        inputBinding:
          position: 2

    outputs:
      demo_csv:
        outputBinding:
            glob: .
        type: Directory