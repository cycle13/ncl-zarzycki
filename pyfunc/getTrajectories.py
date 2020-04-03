import numpy as np

def getTrajectories(filename,nVars,headerDelimStr,isUnstruc):
  print("Getting trajectories from TempestExtremes file...")
  print("Running getTrajectories on '%s' with unstruc set to '%s'" % (filename, isUnstruc))
  print("nVars set to %d and headerDelimStr set to '%s'" % (nVars, headerDelimStr))

  # Using the newer with construct to close the file automatically.
  with open(filename) as f:
      data = f.readlines()

  # Find total number of trajectories and maximum length of trajectories
  numtraj=0
  numPts=[]
  for line in data:
    if headerDelimStr in line:
      # if header line, store number of points in given traj in numPts
      headArr = line.split()
      numtraj += 1
      numPts.append(int(headArr[1]))
    else:
      # if not a header line, and nVars = -1, find number of columns in data point
      if nVars < 0:
        nVars=len(line.split())
  
  maxNumPts = max(numPts) # Maximum length of ANY trajectory

  print("Found %d columns" % nVars)
  print("Found %d trajectories" % numtraj)

  # Initialize storm and line counter
  stormID=-1
  lineOfTraj=-1

  # Create array for data
  if isUnstruc:
    prodata = np.empty((nVars+1,numtraj,maxNumPts))
  else:
    prodata = np.empty((nVars,numtraj,maxNumPts))

  prodata[:] = np.NAN

  for i, line in enumerate(data):
    if headerDelimStr in line:  # check if header string is satisfied
      stormID += 1      # increment storm
      lineOfTraj = 0    # reset trajectory line to zero
    else:
      ptArr = line.split()
      for jj in range(nVars-1):
        if isUnstruc:
          prodata[jj+1,stormID,lineOfTraj]=ptArr[jj]
        else:
          prodata[jj,stormID,lineOfTraj]=ptArr[jj]
      lineOfTraj += 1   # increment line

  print("... done reading data")
  return numtraj, maxNumPts, prodata
