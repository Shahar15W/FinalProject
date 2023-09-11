﻿<%@ Page Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" Async="true" CodeBehind="Main.aspx.cs" Inherits="Prototype.Main" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
		<meta charset="utf-8">
        <link rel="shortcut icon" href="#">
		<title>GameBoard</title>
		<style>
			body { margin: 0; overflow-y: hidden; overflow-x: hidden}
		    canvas {
		        width: 100%;
		        height: 100%;
		        padding: 0px;
		        margin-top: 1px
		    }
		</style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div id="canvas" style="height:100%; padding:0%;margin-top:0%;">
		<script src="js/three.js"></script>
		<script type ="module" src ="js/GLTFLoader.js"></script>
        <script type="text/javascript" src="js/dat.gui.min.js"></script>
        <script type="module" src="js/dat.gui.module.js"></script>

        <script src="Scripts/jquery-3.7.1.min.js"></script>
        <script src="Scripts/jquery.signalR-2.4.3.min.js"></script>
        <script src="http://localhost:8081/hubs"></script>

		<script type ="module">
            import { GLTFLoader } from "./js/GLTFLoader.js";
            import { OrbitControls } from './js/OrbitControls.js';
            import { Vector3 } from "./js/three.module.js";
            import * as dat from './js/dat.gui.module.js';


            var json = (<%= json %>);

            var game = "<%= game %>";

            var lobby = "<%= lobby %>";


            var posdict = {};

            var cursorsin = 0;
            var cursoroffset = 1

            <%foreach(var p in pos)
            { %>
            posdict["<%=p.Key%>"] = "<%=p.Value%>".replace("(", "").replace(")", "").replace(",","");
          <%  }%>

            var playername = "<%=username %>"

            var dict = {};


            var cursordict = {};

            <%foreach(var c in cursors)
            { %>
            cursordict["<%=c.Key%>"] = "<%=c.Value%>".replace("(", "").replace(")", "").replace(",", "");
          <%  }%>

            var cursors = {};


            


			const scene = new THREE.Scene();
            scene.background = new THREE.CubeTextureLoader()
                .setPath('./Backgrounds/Lycksele2/')
                .load([
                    'posx.jpg',
                    'negx.jpg',
                    'posy.jpg',
                    'negy.jpg',
                    'posz.jpg',
                    'negz.jpg'
                ]);
            scene.fog = new THREE.FogExp2(0xcccccc, 0.002);

            window.addEventListener("resize", () => {
                console.log("resize");
                renderer.setSize(window.innerWidth, window.innerHeight);
                camera.aspect = window.innerWidth / window.innerHeight;
                camera.updateProjectionMatrix();
            });

            const renderer = new THREE.WebGLRenderer();
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(window.devicePixelRatio);
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            renderer.shadowCameraNear = 3;
            renderer.toneMapping = THREE.CineonToneMapping;
            renderer.toneMappingExposure = 2.5;

            const pointer = new THREE.Vector2();
            var ground = [];

            const gui = new dat.GUI()

            var cameraObj = null;

            var loader = new GLTFLoader();



            loader.load("./Models/camera.glb", function (gltf) {
                cameraObj = gltf.scene;
                gltf.userData.isContainer = true;

                cameraObj.traverse((child) => {
                    if (child.isMesh) {
                        child.material.transparent = true;
                        child.castShadow = true;
                        child.receiveShadow = true;
                        child.material.metalness = 0;
                        if (child.material.map)
                            child.material.map.anisotropy = 16;
                    }
                })
            });

            var cursorObj = null;

            loader.load("./Models/cursor.glb", function (gltf) {
                cursorObj = gltf.scene;
                gltf.userData.isContainer = true;

                cursorObj.traverse((child) => {
                    if (child.isMesh) {
                        child.material.transparent = true;
                        child.castShadow = true;
                        child.receiveShadow = true;
                        child.material.metalness = 0;
                        if (child.material.map)
                            child.material.map.anisotropy = 16;
                    }
                })
            });

            //adds already logged in players

            const timeout = setTimeout(function (x) { 
                for (var player in posdict) {
                    console.log(player + ' is in the lobby.');


                    var playerpos = posdict[player];
                    var [x, y, z, rx, ry, rz] = playerpos.split(" ");

                    y = y.split(",")[0];
                    z = z.split(",")[0];
                    rx = rx.split(",")[0];
                    ry = ry.split(",")[0];
                    rz = rz.split(",")[0];

                    const playercam = cameraObj.clone();

                    scene.add(playercam);

                    dict[player] = playercam;
                    dict[player].position.set(x, y, z);
                    dict[player].rotation.set(rx, ry, rz);
                    console.log("added camera as " + player + " at " + x + ", " + y + ", " + z)
                }

                for (var cursor in cursordict) {
                    var cursorpos = cursordict[cursor];
                    var [x, y, z] = cursorpos.split(" ");
                    y = y.split(",")[0];
                    z = z.split(",")[0];

                    var playercursor = cursorObj.clone();
                    scene.add(playercursor);

                    cursors[cursor] = playercursor;
                    cursors[cursor].position.set(x, y + cursoroffset, z);
                    cursors[cursor].scale.set(0.03, 0.03, 0.03);
                    console.log("added cursor as " + cursor + " at " + x + ", " + y + ", " + z)
                }
            }, 100);

            // Initialize SignalR connection
            var connection = $.hubConnection(); // Create a SignalR connection
            var lobbyHub = connection.createHubProxy('LobbyHub'); // Create a proxy to your hub
            connection.url = 'http://localhost:8081/Hubs'; // Replace with your hub URL


            //signalr logic
            $(function () {


                // Handle connection error
                connection.error(function (error) {
                    console.error('SignalR connection error:', error); // Log the error in the console
                    // Display an alert to the user
                    alert('Unable to connect to the server. Please try again later.'); // Display an alert
                });

                lobbyHub.on('PlayerJoined', function (playerName) {
                    // Handle player joined event
                    if (!(playerName in dict)) {
                        console.log(playerName + ' joined the lobby.');

                        const playercam = cameraObj.clone();
                        var playercursor = cursorObj.clone();

                        scene.add(playercam);
                        scene.add(playercursor)

                        dict[playerName] = playercam;
                        cursors[playerName] = playercursor;
                        cursors[playerName].scale.set(0.03, 0.03, 0.03);

                        console.log("added camera and cursor as " + playerName)
                    }
                    else {
                        console.log("Player" + playerName + " already in the lobby.")
                    }

                });

                lobbyHub.on('PlayerLeft', function (playerName) {
                    // Handle player left event
                    console.log(playerName + ' left the lobby.');
                    scene.remove(dict[playerName]);
                    scene.remove(cursors[playerName]);

                    delete dict[playerName];
                    delete cursors[playerName];
                });

                lobbyHub.on('LobbyCreated', function (lobbyId) {
                    // Handle player left event
                    console.log(lobbyId + ' created');
                });

                lobbyHub.on('PlayerMoved', function (player, x, y, z, rx, ry, rz) {
                    dict[player].position.set(x, y, z);
                    dict[player].rotation.set(rx, ry, rz);
                });

                lobbyHub.on('CursorMoved', function (player, x, y, z) {
                    cursors[player].position.set(x, y + cursoroffset, z);

                });

                // Define other event handlers as needed

                // Start the SignalR connection
                connection.start().done(function () {
                    // Connection successful
                    console.log('SignalR connection established.');
                    lobbyHub.invoke('JoinLobby', lobby, playername);
                }).fail(function (error) {
                    // Connection failed
                    console.error('SignalR connection error: ' + error);
                });

                connection.disconnected(function () {
                    console.log('SignalR connection disconnected.');
                });

            });


            const Texture = new THREE.TextureLoader().load("./Creations/" + game + "/" + json["Board"]["Texture"]);
            const normal = new THREE.TextureLoader().load("./Creations/" + game + "/" + json["Board"]["Normal"]);
            const ao = new THREE.TextureLoader().load("./Creations/" + game + "/" + json["Board"]["Ao"]);
            const boardgeometry = new THREE.BoxGeometry(20, 0.5, 20)
            const boardmaterial = new THREE.MeshPhongMaterial({ map: Texture, normalMap: normal, aoMap: ao });
            boardmaterial.castShadow = true;
            boardmaterial.receiveShadow = true;
            const board = new THREE.Mesh(boardgeometry, boardmaterial);
            board.position.set(0, 20, 0);
            board.castShadow = true;
            board.receiveShadow = true;
            scene.add(board);
            ground.push(board);

            let floorGeometry = new THREE.PlaneGeometry(2000, 2000, 100, 100);
            let position = floorGeometry.attributes.position;

            const vertex = new THREE.Vector3();
            const color = new THREE.Color();

            for (let i = 0, l = position.count; i < l; i++) {

                vertex.fromBufferAttribute(position, i);

                vertex.x += Math.random() * 20 - 10;
                vertex.y += Math.random() * 1;
                vertex.z += Math.random() * 20 - 10;

                position.setXYZ(i, vertex.x, vertex.y, vertex.z);

            }

            floorGeometry = floorGeometry.toNonIndexed(); // ensure each face has unique vertices

            position = floorGeometry.attributes.position;
            const colorsFloor = [];

            for (let i = 0, l = position.count; i < l; i++) {

                color.setHSL(Math.random() * 0.3 + 0.1, 0.45, Math.random() * 0.25 + 0.35);
                colorsFloor.push(color.r, color.g, color.b);

            }

            floorGeometry.setAttribute('color', new THREE.Float32BufferAttribute(colorsFloor, 3));
            floorGeometry.rotateX(- Math.PI / 2);
            const floorMaterial = new THREE.MeshPhongMaterial({ vertexColors: true });
            floorMaterial.metalness = 10;
            floorMaterial.flatShading = true;
            floorMaterial.receiveShadow = true;
            floorMaterial.castShadow = true;

            const floor = new THREE.Mesh(floorGeometry, floorMaterial);
            scene.add(floor);

            const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);

            render.shadowCameraFar = camera.far;


            document.body.appendChild(renderer.domElement);
            renderer.physicallyCorrectLights = true;


            var obj;

			loader.load("./Models/wooden_table.glb", function (gltf) {
				obj = gltf.scene;
                scene.add(gltf.scene);
                obj.position.set(0, 10, 0);
                obj.scale.set(30, 20, 20);
                obj.name = "table";
                gltf.userData.isContainer = true;

                obj.traverse((child) => {
                    if (child.isMesh) {
                        child.material.transparent = true;
                        child.castShadow = true;
                        child.receiveShadow = true;
                        child.material.metalness = 0;
                        if (child.material.map)
                            child.material.map.anisotropy = 16;
                    }
                })
                ground.push(obj);
            });

            var pathc = "./Models/Dice.glb";
            var objects = [];
            var cubes = [];
            var arrc = json["Cubes"];
            var tmpc;
            var a;

            a = new THREE.Euler(0, 0, 0, 'XYZ');
            loader.load(pathc, function (gltf) {
                tmpc = gltf.scene;

                cubes.push(tmpc);
                for (let i = 0; i < arrc.length; i++) {
                    const instance = tmpc.clone();

                    instance.position.copy(GetVector(arrc[i]["Position"]));
                    instance.scale.copy(GetVector(arrc[i]["Scale"]));

                    instance.traverse((child) => {
                        if (child.isMesh) {


                            child.material.color.setHex(arr[i]["Color"]);
                            child.material.transparent = true;
                            child.castShadow = true;
                            child.receiveShadow = true;
                            if (child.material.map)
                                child.material.map.anisotropy = 16;
                        }
                    });


                    // Calculate the bounding box of the instance
                    const bbox = new THREE.Box3().setFromObject(instance);

                    // Calculate the center of the bounding box
                    const center = bbox.getCenter(new THREE.Vector3());

                    // Create a new Object3D to serve as the pivot point
                    const pivot = new THREE.Object3D();
                    pivot.position.copy(center);

                    // Add the pivot to the scene and the instance to the pivot
                    scene.add(pivot);
                    pivot.add(instance);

                    // Set the instance's pivot point to the center of the bounding box
                    instance.userData.pivot = center.clone();

                    instance.name = i;

                    cubes.push(instance);
                    ground.push(instance);


                    

                    gltf.userData.isContainer = true;
                }


            });

            function rollDice(diceObject) {
                const maxRotations = Math.floor(Math.random() * 10) + 3;
                const targetFace = Math.floor(Math.random() * 6) + 1;
                let currentFace = Math.floor(Math.random() * 6) + 1;
                let rotations = 0;
                let rotationX = 0;
                let rotationY = 0;
                let rotationZ = 0;

                function animateDice() {
                    requestAnimationFrame(animateDice);

                    if (rotations < maxRotations) {
                        diceObject.rotation.x += Math.random() * Math.PI / 2;
                        diceObject.rotation.y += Math.random() * Math.PI / 2;
                        diceObject.rotation.z += Math.random() * Math.PI / 2;
                        rotations++;
                    } else if (currentFace !== targetFace) {
                        switch (currentFace) {
                            case 1:
                                rotationX = -Math.PI / 2;
                                break;
                            case 2:
                                rotationX = Math.PI / 2;
                                break;
                            case 3:
                                rotationY = Math.PI / 2;
                                break;
                            case 4:
                                rotationY = -Math.PI / 2;
                                break;
                            case 5:
                                rotationZ = Math.PI / 2;
                                break;
                            case 6:
                                rotationZ = -Math.PI / 2;
                                break;
                        }
                        currentFace = currentFace % 6 + 1;

                        // Reset rotations
                        rotations = 0;
                    } else {
                        // Stop animation
                        diceObject.rotation.set(rotationX, rotationY, rotationZ);
                        return;
                    }
                }

                animateDice();
            }
            const TestFolder = gui.addFolder("Test");
            TestFolder.open();
            var roll = {
                roll: function () {
                    for (let i = 0; i < cubes.length; i++) {
                        rollDice(cubes[i]);
                    }
                }
            };
            TestFolder.add(roll, 'roll');

            var tmp;
            var path;
            var arr = json["Pieces"]; 
            var tmp;
            for (let i = 0; i < arr.length; i++) {
                a = new THREE.Euler(0, 0, 0, 'XYZ');
                path = "./Creations/" + game + "/" + arr[i]["Model"];
                loader.load(path, function (gltf) {
                    tmp = gltf.scene;
                    scene.add(gltf.scene);
                    tmp.position.copy(GetVector(arr[i]["Position"]));
                    a.setFromVector3(VectorRad(GetVector(arr[i]["Rotation"])));
                    tmp.rotation.copy(a);
                    tmp.scale.copy(GetVector(arr[i]["Scale"]));
                    tmp.name = i;
                    objects.push(tmp);
                    ground.push(tmp);
                    gltf.userData.isContainer = true;

                    tmp.traverse((child) => {
                        if (child.isMesh) {

                            child.material.transparent = true;
                            child.castShadow = true;
                            child.receiveShadow = true;
                            child.material.color.setHex(arr[i]["Color"]);
                            if (child.material.map)
                                child.material.map.anisotropy = 16;
                        }
                    })
                });
                
            }
            var hemiLight = new THREE.HemisphereLight(0xfff5de, 0x1f1f54,0.6);
            scene.add(hemiLight);

            var dirLight = new THREE.DirectionalLight(0xedb137,0.9);
            dirLight.position.set(-30, 70, 10);
            dirLight.castShadow = true;
            dirLight.target.position.set(0, 20, 0);
            scene.add(dirLight);
            scene.add(dirLight.target);
            dirLight.shadow.mapSize.width = 1024 * 3;
            dirLight.shadow.mapSize.height = 1024 * 3;
            dirLight.shadow.bias = -0.0001;
            dirLight.shadow.camera.left = -20;
            dirLight.shadow.camera.right = 20;
            dirLight.shadow.camera.top = 20;
            dirLight.shadow.camera.bottom = -20;
            

            var controls = new OrbitControls(camera, renderer.domElement);
            controls.mouseButtons = {
                LEFT: THREE.MOUSE.RIGHT,
                MIDDLE: THREE.MOUSE.MIDDLE,
                RIGHT: THREE.MOUSE.LEFT };
            controls.listenToKeyEvents(window); // optional
            controls.target = new THREE.Vector3 (0, 15, 0);
            controls.update();
            

            //controls.addEventListener( 'change', render ); // call this only in static scenes (i.e., if there is no animation loop)

            controls.enableDamping = true; // an animation loop is required when either damping or auto-rotation are enabled
            controls.dampingFactor = 0.05;

            controls.screenSpacePanning = false;

            controls.minDistance = 10;
            controls.maxDistance = 50;

            controls.maxPolarAngle = Math.PI / 2;

            document.addEventListener('mousemove', onPointerMove);
            document.addEventListener('click' , onDocumentMouseDown);


            var raycaster = new THREE.Raycaster();
            var intersects;


            var lastcursorvector = new THREE.Vector3(0, 0, 0);

            var lastcameravector = new THREE.Vector3(0, 0, 0);
            var cameralookatlast = new THREE.Vector3();
            var cameralookatcurrent = new THREE.Vector3();
            var currentvector = new THREE.Vector3();

            var lastoffset = 0

            function animate() {
                requestAnimationFrame(animate);

                controls.update(); // only required if controls.enableDamping = true, or if controls.autoRotate = true

                for (var cursor in cursors) {
                    var c = cursors[cursor];
                    c.rotation.set(c.rotation.x, Math.atan2((camera.position.x - c.position.x), (camera.position.z - c.position.z)), c.rotation.z);
                    c.position.set(c.position.x, c.position.y + cursoroffset - lastoffset, c.position.z);
                    lastoffset = cursoroffset;
                    cursoroffset += Math.sin(cursorsin / 30) * 0.02;
                    cursorsin += 1;
                }

                raycaster.setFromCamera(pointer, camera);
                intersects = raycaster.intersectObjects(ground, true);

                currentvector = camera.position.clone()

                cameralookatcurrent = camera.rotation.clone()

                if (Math.abs(currentvector.x - lastcameravector.x) > 0.3 ||
                    Math.abs(currentvector.y - lastcameravector.y) > 0.3 ||
                    Math.abs(currentvector.z - lastcameravector.z) > 0.3 ||
                    Math.abs(cameralookatcurrent.x - cameralookatlast.x) > 0.03 ||
                    Math.abs(cameralookatcurrent.y - cameralookatlast.y) > 0.03 ||
                    Math.abs(cameralookatcurrent.z - cameralookatlast.z) > 0.03
                ) {
                    lobbyHub.invoke('MovePlayer', playername, currentvector.x, currentvector.y, currentvector.z, cameralookatcurrent.x, cameralookatcurrent.y, cameralookatcurrent.z);
                    lastcameravector = currentvector;
                    cameralookatlast = cameralookatcurrent;
                }

                if (intersects.length > 0) {
                    if (Math.abs(intersects[0].point.x - lastcursorvector.x) > 0.03 ||
                        Math.abs(intersects[0].point.y - lastcursorvector.y) > 0.03 ||
                        Math.abs(intersects[0].point.z - lastcursorvector.z) > 0.03) {
                        
                        lobbyHub.invoke('MoveCursor', playername, intersects[0].point.x, intersects[0].point.y, intersects[0].point.z);
                        lastcursorvector = intersects[0].point;
                    }
                }

                if (select != null) {
                    
                    if (intersects.length > 0) {
                        select.position.x = (intersects[0].point.x);
                        select.position.y = (intersects[0].point.y);
                        select.position.z = (intersects[0].point.z );
                    }
                    document.onkeydown = function (e) {
                        switch (e.keyCode) {
                            case 65:
                                select.rotation.y += 0.1;
                                break;
                            case 68:
                                select.rotation.y -= 0.1;
                                break;
                        }
                    };
                }
                
                render();
            }
            function render() {

                renderer.render(scene, camera);

            }
            
            animate();
            var select = null;


            function onDocumentMouseDown(event) {
                event.preventDefault();

                var raycaster = new THREE.Raycaster();
                raycaster.setFromCamera(pointer, camera);
                if (select == null) {
                    var intersects = raycaster.intersectObjects(objects, true);
                    if (intersects.length > 0) {
                        controls.enablePan = false;
                        select = intersects[0].object;
                        while (select.parent.type !== "Scene") {
                            select = select.parent;
                        }
                        if (!objects.includes(select)) {
                            rot = new THREE.Vector3(Math.floor(Math.random() * 7), Math.floor(Math.random() * 7), Math.floor(Math.random() * 7));
                            Rotate(select, rot);
                            select = null;
                        }
                        else {
                            ground.splice(ground.indexOf(select), 1);

                            select.traverse((child) => {
                                if (child.isMesh) {
                                    child.material.opacity = 0.6;
                                    child.material.color.setHex("0xFF5733");
                                    child.material.emissive.setHex("0xFF5733");
                                }
                            })
                        }

                    }
                }
                else {
                    var intersects = raycaster.intersectObjects(ground, true);
                    if (intersects.length > 0) {
                        select.position.x = (intersects[0].point.x );
                        select.position.y = intersects[0].point.y;
                        select.position.z = (intersects[0].point.z);
                        ground.push(select);
                        controls.enablePan = true;

                        select.traverse((child) => {
                            if (child.isMesh) {
                                child.material.opacity = 1;
                                child.material.color.setHex(json["Pieces"][select.name]["Color"]);
                                child.material.emissive.setHex("0x000000");

                            }
                        })

                        select = null;

                    }
                }

            }
            function onPointerMove(event) {

                pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
                pointer.y = - (event.clientY / window.innerHeight) * 2 + 1;
            }
            function GetVector(data) {
                var res = new THREE.Vector3(0,0,0);
                res.x = data["X"];
                res.y = data["Y"];
                res.z = data["Z"];
                return res;
            }
            function VectorRad(vector) {
                var res = new THREE.Vector3(0, 0, 0);
                res.x = vector.x * Math.PI / 180;
                res.y = vector.y * Math.PI / 180;
                res.z = vector.z * Math.PI / 180;

                return res;
            }

            function Rotate(object, vector) {
                for (let i = 0; i < vector.x; i++) {
                    object.rotation.x += Math.PI/ 2;
                }
                for (let i = 0; i < vector.y; i++) {
                    object.rotation.y += Math.PI/ 2;
                }
                for (let i = 0; i < vector.z; i++) {
                    object.rotation.z += Math.PI/ 2;
                }
            }

			//Our Javascript will go here.

        </script>
        </div>
</asp:Content>
