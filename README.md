# VoxelBuffer
With the VoxelBuffer you can set Smooth Terrain voxels anywhere without having to worry about Region bounds or 4x4 alignment. You can
set thousands of them (up to the limits of your computer) then commit them all at once to your Terrain in one call.

It works by internally dividing world space up into regions and tracking changes within those regions in
dynamically generated buffers.

NOTE: when a new buffered region is created, either by setting or getting a voxel, it is populated by reading
the voxels from the current Terrain

The VoxelBuffer has 3 main functions, setVoxel(x, y, z, material, occupancy), getVoxel(x, y, z) and commitToTerrian().

# Simple example:

	local voxelBuffer = voxelBuffer.VoxelBuffer.new()

	voxelBuffer:setVoxel(100, 100, 100, Enum.Material.Ground, 1)
	voxelBuffer:setVoxel(10000, 10000, 10000, Enum.Material.Ground, 1)
	voxelBuffer:commitToTerrian()
	
NOTE: setVoxel() and getVoxel() take world space block locations but Terrain voxels are 4x4 blocks, 
so calling setVoxel(0, 0, 0, m, 1) and setVoxel(3, 3, 3, m, 1) sets
the exact same voxel twice.

# Demo

To run the demo create a VoxelBuffer module script in ReplicatedStorage and paste the code from VoxelBuffer.lua into it.
Then create a VoxelBufferDemo script somewhere it will run, and paste the code from VoxelBufferDemo.lua into it.
